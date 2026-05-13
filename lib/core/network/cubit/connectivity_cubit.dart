import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_specialized_temp/core/logger/app_logger.dart';
import 'package:flutter_specialized_temp/core/network/services/connection_manager.dart';
import 'package:injectable/injectable.dart';

/// Cubit that manages global connectivity state
///
/// Listens to ConnectionManager's stream and emits connectivity changes
/// to the entire app. This allows any widget to react to connectivity changes.
@injectable
class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit(this._connectionManager) : super(ConnectivityInitial()) {
    _init();
  }
  final ConnectionManager _connectionManager;
  StreamSubscription<bool>? _connectivitySubscription;

  void _init() {
    // Start monitoring connectivity
    _connectionManager.startMonitoring();

    // Set initial state based on current connection
    if (_connectionManager.isConnected) {
      emit(ConnectedState());
    } else {
      emit(DisconnectedState());
    }

    // Listen to connectivity changes
    _connectivitySubscription = _connectionManager.connectivityStream.listen((
      isConnected,
    ) {
      if (isConnected) {
        AppLogger.i(message: '🌐 ConnectivityCubit: Online');
        emit(ConnectedState());
      } else {
        AppLogger.w(message: '🌐 ConnectivityCubit: Offline');
        emit(DisconnectedState());
      }
    });
  }

  /// Check current connectivity status
  bool get isConnected => _connectionManager.isConnected;

  /// Manually refresh connectivity status
  Future<void> refresh() async {
    emit(ConnectivityChecking());
    final isConnected = await _connectionManager.checkInternetConnection();
    if (isConnected) {
      emit(ConnectedState());
    } else {
      emit(DisconnectedState());
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    _connectionManager.stopMonitoring();
    return super.close();
  }
}

/// Base connectivity state
abstract class ConnectivityState extends Equatable {
  const ConnectivityState();

  @override
  List<Object?> get props => [];
}

/// Initial state before connectivity is checked
class ConnectivityInitial extends ConnectivityState {}

/// State when checking connectivity
class ConnectivityChecking extends ConnectivityState {}

/// State when device is connected to internet
class ConnectedState extends ConnectivityState {}

/// State when device is disconnected from internet
class DisconnectedState extends ConnectivityState {}
