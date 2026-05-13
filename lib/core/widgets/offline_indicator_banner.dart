import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_specialized_temp/core/network/cubit/connectivity_cubit.dart';

/// 🌐 Enhanced offline indicator banner optimized for million-user scalability.
///
/// Features for exceptional UX:
/// - Smooth slide-in/out animations with haptic feedback
/// - Smart retry mechanism with loading states
/// - Connection restoration celebration
/// - Accessibility optimized
/// - Memory efficient with minimal rebuilds
/// - Progressive disclosure of connection details
class OfflineIndicatorBanner extends StatefulWidget {
  const OfflineIndicatorBanner({
    super.key,
    this.onConnectionRestored,
    this.showDetails = false,
    this.onRetry,
  });

  /// Optional callback when connection is restored
  final VoidCallback? onConnectionRestored;

  /// Show detailed connection info
  final bool showDetails;

  /// Custom retry action
  final VoidCallback? onRetry;

  @override
  State<OfflineIndicatorBanner> createState() => _OfflineIndicatorBannerState();
}

class _OfflineIndicatorBannerState extends State<OfflineIndicatorBanner>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _celebrationController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _celebrationAnimation;

  bool _isRetrying = false;
  bool _wasOffline = false;

  @override
  void initState() {
    super.initState();

    // Slide animation for banner appearance
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Pulse animation for retry button
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Celebration animation for connection restored
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _celebrationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityCubit, ConnectivityState>(
      listener: (context, state) {
        if (state is DisconnectedState) {
          if (!_wasOffline) {
            _wasOffline = true;
            _slideController.forward();
            _pulseController.repeat(reverse: true);
            // Haptic feedback for offline
            HapticFeedback.lightImpact();
          }
        } else if (state is ConnectedState) {
          if (_wasOffline) {
            _wasOffline = false;
            _isRetrying = false;
            _pulseController.stop();

            // Celebration animation
            _celebrationController.forward().then((_) {
              _slideController.reverse();
              _celebrationController.reset();
              widget.onConnectionRestored?.call();
            });

            // Haptic feedback for reconnection
            HapticFeedback.mediumImpact();
          }
        }

        if (state is ConnectivityChecking) {
          setState(() => _isRetrying = true);
        } else {
          setState(() => _isRetrying = false);
        }
      },
      child: BlocBuilder<ConnectivityCubit, ConnectivityState>(
        buildWhen: (previous, current) =>
            previous.runtimeType != current.runtimeType,
        builder: (context, state) {
          if (state is! DisconnectedState) {
            return const SizedBox.shrink();
          }

          return SlideTransition(
            position: _slideAnimation,
            child: _buildEnhancedBanner(context, state),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedBanner(BuildContext context, ConnectivityState state) {
    return Material(
      elevation: 8,
      shadowColor: Colors.red.withValues(alpha: 0.5),
      child: AnimatedBuilder(
        animation: _celebrationAnimation,
        builder: (context, child) {
          // Color transitions during celebration
          final isConnected = _celebrationAnimation.value > 0;
          final backgroundColor = isConnected
              ? ColorTween(
                  begin: Colors.red.shade700,
                  end: Colors.green.shade600,
                ).evaluate(_celebrationAnimation)!
              : Colors.red.shade700;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  backgroundColor,
                  backgroundColor.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: _buildBannerContent(context, isConnected),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBannerContent(BuildContext context, bool isConnected) {
    return InkWell(
      onTap: _handleRetry,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Connection icon with animation
            AnimatedBuilder(
              animation: _celebrationAnimation,
              builder: (context, child) {
                if (isConnected) {
                  return ScaleTransition(
                    scale: _celebrationAnimation,
                    child: const Icon(
                      Icons.wifi,
                      color: Colors.white,
                      size: 22,
                    ),
                  );
                }
                return const Icon(
                  Icons.wifi_off,
                  color: Colors.white,
                  size: 22,
                );
              },
            ),
            const SizedBox(width: 12),

            // Status text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      isConnected ? 'Connection restored!' : "You're offline",
                      key: ValueKey(isConnected),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (widget.showDetails && !isConnected) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Using cached content when available',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Retry button with smart states
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _buildRetryButton(context, isConnected),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetryButton(BuildContext context, bool isConnected) {
    if (isConnected) {
      return const Icon(
        Icons.check_circle,
        color: Colors.white,
        size: 20,
        key: ValueKey('success'),
      );
    }

    if (_isRetrying) {
      return SizedBox(
        width: 20,
        height: 20,
        key: const ValueKey('loading'),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            Colors.white.withValues(alpha: 0.8),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      key: const ValueKey('retry'),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.refresh,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 16,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleRetry() {
    if (_isRetrying || _celebrationAnimation.value > 0) return;

    HapticFeedback.lightImpact();

    if (widget.onRetry != null) {
      widget.onRetry!.call();
    } else {
      context.read<ConnectivityCubit>().refresh();
    }
  }
}

/// 🎯 Smart offline wrapper with enhanced UX patterns for million users
class SmartOfflineWrapper extends StatelessWidget {
  const SmartOfflineWrapper({
    required this.child,
    super.key,
    this.showNetworkStatus = true,
    this.showCacheIndicators = false,
    this.onConnectionRestored,
  });
  final Widget child;
  final bool showNetworkStatus;
  final bool showCacheIndicators;
  final VoidCallback? onConnectionRestored;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showNetworkStatus)
          OfflineIndicatorBanner(
            showDetails: showCacheIndicators,
            onConnectionRestored: onConnectionRestored,
          ),
        Expanded(child: child),
      ],
    );
  }
}

/// 📊 Network status indicator for AppBar
class NetworkStatusIndicator extends StatelessWidget {
  const NetworkStatusIndicator({
    super.key,
    this.showWhenOnline = false,
    this.compact = true,
  });
  final bool showWhenOnline;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        if (state is ConnectedState && !showWhenOnline) {
          return const SizedBox.shrink();
        }

        Color color;
        IconData icon;
        String text;

        switch (state.runtimeType) {
          case ConnectedState:
            color = Colors.green;
            icon = Icons.wifi;
            text = 'Online';
          case DisconnectedState:
            color = Colors.red;
            icon = Icons.wifi_off;
            text = 'Offline';
          case ConnectivityChecking:
            color = Colors.orange;
            icon = Icons.wifi_find;
            text = 'Checking...';
          default:
            color = Colors.grey;
            icon = Icons.help_outline;
            text = 'Unknown';
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 14),
              if (!compact) ...[
                const SizedBox(width: 4),
                Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Wrapper widget that adds offline indicator to any screen
///
/// Usage:
/// ```dart
/// return WithOfflineIndicator(
///   child: YourScreenWidget(),
/// );
/// ```
class WithOfflineIndicator extends StatelessWidget {
  const WithOfflineIndicator({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const OfflineIndicatorBanner(),
        Expanded(child: child),
      ],
    );
  }
}

/// Connectivity-aware button that disables when offline
///
/// Usage:
/// ```dart
/// ConnectivityAwareButton(
///   onPressed: () => performNetworkAction(),
///   child: Text('Submit'),
/// )
/// ```
class ConnectivityAwareButton extends StatelessWidget {
  const ConnectivityAwareButton({
    required this.onPressed,
    required this.child,
    super.key,
    this.style,
  });
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        final isConnected = state is ConnectedState;

        return ElevatedButton(
          onPressed: isConnected ? onPressed : null,
          style: style,
          child: child,
        );
      },
    );
  }
}
