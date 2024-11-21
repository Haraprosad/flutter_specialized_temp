import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/post_bloc.dart';
import '../bloc/post_event.dart';
import '../bloc/post_state.dart';
import '../widgets/post_list.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  @override
  void initState() {
    super.initState();
    // Dispatch the event here to ensure it's triggered only once
    context.read<PostsBloc>().add(PostsFetched());
  }

  Future<void> _onRefresh() async {
    context.read<PostsBloc>().add(PostsFetched());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
      ),
      body: BlocBuilder<PostsBloc, PostsState>(
        builder: (context, state) {
          if (state.isLoading && state.posts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.failure != null && state.posts.isEmpty) {
            return Center(
              child: Text(state.failure?.translatedMessage ?? 'Something went wrong'),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: const PostList(),
          );
        },
      ),
    );
  }
}
