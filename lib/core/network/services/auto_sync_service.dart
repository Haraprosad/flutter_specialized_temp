import 'dart:async';

import 'package:flutter_specialized_temp/core/logger/app_logger.dart';
import 'package:flutter_specialized_temp/core/network/queue/mutation_queue.dart';
import 'package:flutter_specialized_temp/core/network/services/connection_manager.dart';
import 'package:injectable/injectable.dart';

/// Service that automatically syncs queued mutations when connection is restored
///
/// Features:
/// - Listen to connectivity changes
/// - Auto-sync queue when online
/// - Handle sync failures gracefully
/// - Notify listeners of sync status
@lazySingleton
class AutoSyncService {
  AutoSyncService(this._mutationQueue, this._connectionManager);
  final MutationQueue _mutationQueue;
  final ConnectionManager _connectionManager;

  StreamSubscription<bool>? _connectivitySubscription;
  bool _isSyncing = false;

  // Callback for custom mutation execution
  Future<bool> Function(QueuedMutation)? _mutationExecutor;

  /// Start auto-sync service
  ///
  /// @param executor: Function to execute each mutation
  void startAutoSync({
    required Future<bool> Function(QueuedMutation) executor,
  }) {
    _mutationExecutor = executor;

    AppLogger.i(message: '🔄 Starting auto-sync service...');

    // Listen to connectivity changes
    _connectivitySubscription = _connectionManager.connectivityStream.listen((
      isConnected,
    ) {
      if (isConnected) {
        _onConnectionRestored();
      }
    });

    // Check immediately if we're already online
    if (_connectionManager.isConnected) {
      _onConnectionRestored();
    }
  }

  /// Stop auto-sync service
  void stopAutoSync() {
    AppLogger.i(message: '🛑 Stopping auto-sync service...');
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// Manually trigger sync
  Future<bool> manualSync() async {
    if (_mutationExecutor == null) {
      AppLogger.w(message: '⚠️ Cannot sync: No mutation executor configured');
      return false;
    }

    return _syncQueue();
  }

  /// Handle connection restored event
  Future<void> _onConnectionRestored() async {
    if (!_mutationQueue.hasPendingMutations) {
      AppLogger.d(message: '📭 No pending mutations to sync');
      return;
    }

    if (_isSyncing) {
      AppLogger.d(message: '⏳ Sync already in progress, skipping...');
      return;
    }

    AppLogger.i(
      message:
          '🌐 Connection restored, syncing ${_mutationQueue.queueSize} pending mutations...',
    );

    await _syncQueue();
  }

  /// Sync queue with server
  Future<bool> _syncQueue() async {
    if (_mutationExecutor == null) {
      return false;
    }

    _isSyncing = true;

    try {
      final successCount = await _mutationQueue.processQueue(
        executor: _mutationExecutor!,
      );

      if (successCount > 0) {
        AppLogger.i(message: '✅ Successfully synced $successCount mutations');
      }

      return successCount > 0;
    } catch (e, stackTrace) {
      AppLogger.e(
        message: '❌ Error during auto-sync',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  /// Check if currently syncing
  bool get isSyncing => _isSyncing;

  /// Check if has pending mutations
  bool get hasPendingMutations => _mutationQueue.hasPendingMutations;

  /// Get pending mutations count
  int get pendingCount => _mutationQueue.queueSize;

  /// Dispose resources
  void dispose() {
    stopAutoSync();
  }
}
