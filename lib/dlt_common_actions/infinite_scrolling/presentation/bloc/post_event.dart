import 'package:equatable/equatable.dart';

sealed class PostsEvent extends Equatable {
  const PostsEvent();

  @override
  List<Object> get props => [];
}

final class PostsFetched extends PostsEvent {}
final class PostsLoadMore extends PostsEvent {}
