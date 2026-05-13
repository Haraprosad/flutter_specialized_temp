import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_specialized_temp/core/network/cubit/connectivity_cubit.dart';
import 'package:flutter_specialized_temp/core/widgets/network_aware_page.dart';

/// 🚀 EXAMPLE: How to create a new network-aware page professionally
///
/// This example demonstrates the ZERO CODE DUPLICATION approach.
/// All network handling is done by NetworkAwarePage - no redundant code!
///
/// **Key Benefits:**
/// - ✅ Automatic offline banner
/// - ✅ Real-time network status indicator
/// - ✅ Network-aware error states
/// - ✅ Smart refresh on connection restoration
/// - ✅ Consistent UX across all pages
/// - ✅ ZERO network-related code duplication

// Example 1: Simple Page with Network Awareness
class SimpleNetworkAwarePage extends StatelessWidget {
  const SimpleNetworkAwarePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const NetworkAwarePage(
      title: 'My Feature',
      body: Center(child: Text('Your content here')),
    );
  }
}

// Example 2: Page with BLoC Integration
class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkAwarePage(
      title: 'Products',

      // 🚀 Auto-refresh when connection is restored
      onConnectionRestored: () {
        // context.read<ProductsBloc>().add(const ProductsRefresh());
      },

      // 📊 Custom AppBar actions (performance metrics, filters, etc.)
      actions: [
        // Example: Performance metrics chip
        // BlocBuilder<ProductsBloc, ProductsState>(
        //   builder: (context, state) {
        //     if (state.performanceMetrics != null) {
        //       return Chip(
        //         label: Text('${state.performanceMetrics!.loadTime}ms'),
        //       );
        //     }
        //     return SizedBox.shrink();
        //   },
        // ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {
            // Show filter dialog
          },
        ),
      ],

      // 🔄 Enable pull-to-refresh
      enableRefresh: true,
      onRefresh: () async {
        // context.read<ProductsBloc>().add(const ProductsRefresh());
        await Future<void>.delayed(const Duration(milliseconds: 500));
      },

      body: const _ProductsContent(),
    );
  }
}

class _ProductsContent extends StatelessWidget {
  const _ProductsContent();

  @override
  Widget build(BuildContext context) {
    // Replace this with your actual BLoC builder
    return const _ProductsContentExample();
  }
}

// Example 3: Complete BLoC Integration Pattern
class _ProductsContentExample extends StatelessWidget {
  const _ProductsContentExample();

  @override
  Widget build(BuildContext context) {
    // Example structure - replace with your actual BLoC.
    // Example loading check:
    //   if (isLoading && !hasData) return const NetworkAwareLoadingState();
    // Example error check:
    //   if (hasError && !hasData) return NetworkAwareErrorState(...);

    // ✅ Success state with data
    return ListView.builder(
      itemCount: 20,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            title: Text('Product $index'),
            subtitle: Text('Description for product $index'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to details
            },
          ),
        );
      },
    );
  }
}

// Example 4: Page with Network Status but No Offline Banner
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const NetworkAwarePage(
      title: 'Settings',
      showOfflineBanner: false, // Hide banner for settings page
      body: Center(child: Text('Settings content')),
    );
  }
}

// Example 5: Page with Custom Error Handling
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkAwarePage(
      title: 'Orders',
      body: const _OrdersContent(),

      // Custom actions
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // Open search
          },
        ),
      ],

      // FAB for new order
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Create new order
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _OrdersContent extends StatelessWidget {
  const _OrdersContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, connectivityState) {
        // Example: Show different content based on connectivity
        final isOffline = connectivityState is DisconnectedState;

        return Column(
          children: [
            if (isOffline)
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.amber.shade100,
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Showing cached orders. Connect to see latest.',
                        style: TextStyle(color: Colors.amber.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(title: Text('Order #1234')),
                  ListTile(title: Text('Order #1235')),
                  ListTile(title: Text('Order #1236')),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 📚 PROFESSIONAL PATTERNS FOR NEW PAGES
///
/// ═══════════════════════════════════════════════════════════════════
/// Pattern 1: Standard BLoC Page
/// ═══════════════════════════════════════════════════════════════════
///
/// class MyPage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return NetworkAwarePage(
///       title: 'My Feature',
///       onConnectionRestored: () {
///         context.read<MyBloc>().add(RefreshEvent());
///       },
///       body: BlocBuilder<MyBloc, MyState>(
///         builder: (context, state) {
///           if (state.isLoading && !state.hasData) {
///             return NetworkAwareLoadingState(
///               itemBuilder: (context, index) => MyShimmer(),
///             );
///           }
///
///           if (state.hasError && !state.hasData) {
///             return NetworkAwareErrorState(
///               errorMessage: state.failure?.message,
///               onRetry: () => context.read<MyBloc>().add(FetchEvent()),
///             );
///           }
///
///           return MyContentWidget(data: state.data);
///         },
///       ),
///     );
///   }
/// }
///
/// ═══════════════════════════════════════════════════════════════════
/// Pattern 2: Page with Custom Refresh Logic
/// ═══════════════════════════════════════════════════════════════════
///
/// class MyPage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return NetworkAwarePage(
///       title: 'My Feature',
///       enableRefresh: true,
///       onRefresh: () async {
///         final bloc = context.read<MyBloc>();
///         bloc.add(const RefreshEvent());
///
///         // Wait for completion
///         await bloc.stream.firstWhere(
///           (state) => !state.isRefreshing,
///         );
///       },
///       body: MyContent(),
///     );
///   }
/// }
///
/// ═══════════════════════════════════════════════════════════════════
/// Pattern 3: Page with Performance Metrics
/// ═══════════════════════════════════════════════════════════════════
///
/// class MyPage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return NetworkAwarePage(
///       title: 'My Feature',
///       actions: [
///         BlocBuilder<MyBloc, MyState>(
///           buildWhen: (prev, curr) =>
///             prev.performanceMetrics != curr.performanceMetrics,
///           builder: (context, state) {
///             if (state.performanceMetrics != null) {
///               return Tooltip(
///                 message: state.isFromCache
///                   ? 'Loaded from cache'
///                   : 'Loaded from network',
///                 child: Chip(
///                   label: Text('${state.performanceMetrics!.loadTime}ms'),
///                   backgroundColor: state.isFromCache
///                     ? Colors.green.shade100
///                     : Colors.blue.shade100,
///                 ),
///               );
///             }
///             return SizedBox.shrink();
///           },
///         ),
///       ],
///       body: MyContent(),
///     );
///   }
/// }
///
/// ═══════════════════════════════════════════════════════════════════
/// Pattern 4: Minimal Page (No Network Indicators)
/// ═══════════════════════════════════════════════════════════════════
///
/// class MyPage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return NetworkAwarePage(
///       title: 'My Feature',
///       showNetworkStatusInAppBar: false,
///       showOfflineBanner: false,
///       body: MyContent(),
///     );
///   }
/// }
