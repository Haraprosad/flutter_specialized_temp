import 'package:flutter_specialized_temp/dlt_common_actions/infinite_scrolling/domain/entities/post.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_model.freezed.dart';
part 'post_model.g.dart';

@freezed
class PostModel with _$PostModel {
  const factory PostModel({
    required int id,
    @Default("") String title,
    @Default("") String body,
  }) = _PostModel;

  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

  const PostModel._();

  Post toEntity()=> Post(
    id: id,
    title: title,
    body: body,
  );

}
