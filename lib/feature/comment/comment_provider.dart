import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/extension/future_extension.dart';
import 'package:otraku/feature/comment/comment_model.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';
import 'package:otraku/util/graphql.dart';

final commentProvider =
    AsyncNotifierProvider.autoDispose.family<CommentNotifier, Comment, int>(
  CommentNotifier.new,
);

class CommentNotifier extends AutoDisposeFamilyAsyncNotifier<Comment, int> {
  @override
  FutureOr<Comment> build(int arg) async {
    final data = await ref
        .read(repositoryProvider)
        .request(GqlQuery.comment, {'id': arg});

    // The response is a list of comments that match the filter criteria.
    // Since we're filtering by id, we expect exactly one comment.
    final comments = data['ThreadComment'];
    if (comments.isEmpty) {
      throw Exception('Not Found');
    }

    // The response always starts from the root comment,
    // even if a subcomment was requested.
    // We search for the requested subcomment with BFS.
    final queue = Queue<Map<String, dynamic>>();
    queue.add(comments[0]);
    while (queue.isNotEmpty) {
      final comment = queue.removeFirst();
      if (comment['id'] == arg) {
        return Comment(comment);
      }

      for (final child in comment['childComments'] ?? const []) {
        queue.addLast(child);
      }
    }

    throw Exception('Not Found');
  }

  void edit(Map<String, dynamic> map) =>
      state = state.whenData((data) => data.withEditedText(map['comment']));

  Future<Object?> toggleCommentLike(int commentId) {
    return ref.read(repositoryProvider).request(
      GqlMutation.toggleLike,
      {'id': commentId, 'type': 'THREAD_COMMENT'},
    ).getErrorOrNull();
  }

  void appendComment(Map<String, dynamic> map, int parentCommentId) {
    final value = state.valueOrNull;
    if (value == null) return;

    state = AsyncValue.data(
      value.withAppendedChildComment(map, parentCommentId),
    );
  }

  Future<Object?> delete() => ref
      .read(repositoryProvider)
      .request(GqlMutation.deleteComment, {'id': arg}).getErrorOrNull();
}
