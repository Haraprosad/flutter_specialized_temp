import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_specialized_temp/dlt_common_actions/infinite_scrolling/presentation/bloc/post_bloc.dart';
import 'package:flutter_specialized_temp/dlt_common_actions/infinite_scrolling/presentation/bloc/post_event.dart';
import 'package:flutter_specialized_temp/dlt_common_actions/infinite_scrolling/presentation/bloc/post_state.dart';
import 'package:flutter_specialized_temp/dlt_common_actions/infinite_scrolling/presentation/widgets/bottom_loader.dart';
import 'package:flutter_specialized_temp/dlt_common_actions/infinite_scrolling/presentation/widgets/post_item.dart';

class PostList extends StatefulWidget {
  const PostList({super.key});

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<PostsBloc>().add(PostsLoadMore());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostsBloc, PostsState>(
      builder: (context, state) {
        return ListView.builder(
          controller: _scrollController,
          itemCount: state.posts.length + (state.hasReachedMax ? 0 : 1),
          itemBuilder: (context, index) {
            if (index >= state.posts.length) {
              return state.isPaginationLoading 
                ? const BottomLoader() 
                : const SizedBox.shrink();
            }
            return PostItem(post: state.posts[index]);
          },
        );
      },
    );
  }
}
