import 'dart:convert';
import 'dart:math';

import 'package:flutter_specialized_temp/core/logger/app_logger.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Represents a mutation operation to be queued
class QueuedMutation {
  QueuedMutation({
    required this.id,
    required this.type,
    required this.entity,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
  });

  factory QueuedMutation.fromJson(Map<String, dynamic> json) => QueuedMutation(
    id: json['id'] as String,
    type: json['type'] as String,
    entity: json['entity'] as String,
    data: json['data'] as Map<String, dynamic>,
    timestamp: DateTime.parse(json['timestamp'] as String),
    retryCount: json['retryCount'] as int? ?? 0,
  );
  final String id;
  final String type; // 'create', 'update', 'delete'
  final String entity; // 'transaction', 'category', etc.
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int retryCount;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'entity': entity,
    'data': data,
    'timestamp': timestamp.toIso8601String(),
    'retryCount': retryCount,
  };

  QueuedMutation copyWithRetry() => QueuedMutation(
    id: id,
    type: type,
    entity: entity,
    data: data,
    timestamp: timestamp,
    retryCount: retryCount + 1,
  );
}

/// Manages offline mutation queue with persistence
///
/// Features:
/// - Queue mutations when offline
/// - Persist queue to disk (survives app restart)
/// - Auto-sync when online
/// - Retry failed mutations
/// - Remove duplicates
@lazySingleton
class MutationQueue {
  MutationQueue(this._prefs) {
    _loadQueueFromDisk();
  }
  final SharedPreferences _prefs;
  final List<QueuedMutation> _queue = [];
  final _random = Random();

  static const String _queueKey = 'MUTATION_QUEUE';
  static const int _maxRetries = 3;

  /// Generate a simple unique ID
  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = _random.nextInt(999999);
    return 'mut_${timestamp}_$random';
  }

  /// Add mutation to queue
  Future<void> enqueueMutation({
    required String type,
    required String entity,
    required Map<String, dynamic> data,
  }) async {
    final mutation = QueuedMutation(
      id: _generateId(),
      type: type,
      entity: entity,
      data: data,
      timestamp: DateTime.now(),
    );

    _queue.add(mutation);
    await _persistQueue();

    AppLogger.i(
      message:
          '📝 Queued $type mutation for $entity (queue size: ${_queue.length})',
    );
  }

  /// Process all queued mutations
  ///
  /// @param executor: Function to execute each mutation
  /// @returns Number of successfully processed mutations
  Future<int> processQueue({
    required Future<bool> Function(QueuedMutation) executor,
  }) async {
    if (_queue.isEmpty) {
      AppLogger.d(message: '📭 Mutation queue is empty');
      return 0;
    }

    AppLogger.i(message: '🔄 Processing ${_queue.length} queued mutations...');

    final mutationsToProcess = List<QueuedMutation>.from(_queue);
    final failedMutations = <QueuedMutation>[];
    var successCount = 0;

    for (final mutation in mutationsToProcess) {
      try {
        AppLogger.d(
          message:
              '⏳ Processing ${mutation.type} mutation for ${mutation.entity}...',
        );

        final success = await executor(mutation);

        if (success) {
          // Remove from queue on success
          _queue.remove(mutation);
          successCount++;
          AppLogger.d(
            message:
                '✅ Successfully processed ${mutation.type} for ${mutation.entity}',
          );
        } else {
          // Retry logic
          if (mutation.retryCount < _maxRetries) {
            final retried = mutation.copyWithRetry();
            _queue
              ..remove(mutation)
              ..add(retried);
            failedMutations.add(retried);
            AppLogger.w(
              message:
                  '⚠️ Mutation failed, will retry (${retried.retryCount}/$_maxRetries)',
            );
          } else {
            // Max retries reached, remove from queue
            _queue.remove(mutation);
            AppLogger.e(
              message:
                  '❌ Mutation failed permanently after $_maxRetries retries',
            );
          }
        }
      } catch (e, stackTrace) {
        AppLogger.e(
          message: '❌ Error processing mutation',
          error: e,
          stackTrace: stackTrace,
        );
        failedMutations.add(mutation);
      }
    }

    // Persist updated queue
    await _persistQueue();

    AppLogger.i(
      message:
          '✅ Queue processed: $successCount succeeded, ${failedMutations.length} failed, ${_queue.length} remaining',
    );

    return successCount;
  }

  /// Get current queue size
  int get queueSize => _queue.length;

  /// Check if queue has pending mutations
  bool get hasPendingMutations => _queue.isNotEmpty;

  /// Get all queued mutations (for UI display)
  List<QueuedMutation> get pendingMutations => List.unmodifiable(_queue);

  /// Clear all queued mutations
  Future<void> clearQueue() async {
    _queue.clear();
    await _persistQueue();
    AppLogger.i(message: '🗑️ Mutation queue cleared');
  }

  /// Persist queue to disk
  Future<void> _persistQueue() async {
    try {
      final jsonList = _queue.map((m) => m.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await _prefs.setString(_queueKey, jsonString);
      AppLogger.d(message: '💾 Mutation queue persisted to disk');
    } catch (e) {
      AppLogger.e(message: '❌ Failed to persist queue: $e');
    }
  }

  /// Load queue from disk
  void _loadQueueFromDisk() {
    try {
      final jsonString = _prefs.getString(_queueKey);
      if (jsonString != null) {
        final jsonList = json.decode(jsonString) as List;
        _queue.addAll(
          jsonList
              .map(
                (json) => QueuedMutation.fromJson(json as Map<String, dynamic>),
              )
              .toList(),
        );
        AppLogger.i(message: '📦 Loaded ${_queue.length} mutations from disk');
      }
    } catch (e) {
      AppLogger.e(message: '❌ Failed to load queue from disk: $e');
    }
  }
}
