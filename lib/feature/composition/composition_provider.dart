import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/extension/string_extension.dart';
import 'package:otraku/util/graphql.dart';
import 'package:otraku/feature/composition/composition_model.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';

final compositionProvider = AsyncNotifierProvider.autoDispose
    .family<CompositionNotifier, Composition, CompositionTag>(CompositionNotifier.new);

class CompositionNotifier extends AsyncNotifier<Composition> {
  CompositionNotifier(this.arg);

  final CompositionTag arg;

  @override
  FutureOr<Composition> build() {
    if (arg.id == null) {
      return switch (arg) {
        MessageActivityCompositionTag _ => PrivateComposition('', false),
        _ => Composition(''),
      };
    }

    return switch (arg) {
      StatusActivityCompositionTag(id: var id) =>
        ref
            .read(repositoryProvider)
            .request(GqlQuery.activityComposition, {'id': id})
            .then((data) => Composition(data['Activity']['text'])),
      MessageActivityCompositionTag(id: var id) =>
        ref
            .read(repositoryProvider)
            .request(GqlQuery.activityComposition, {'id': id})
            .then((data) => Composition(data['Activity']['message'])),
      ActivityReplyCompositionTag(id: var id) =>
        ref
            .read(repositoryProvider)
            .request(GqlQuery.activityReplyComposition, {'id': id})
            .then((data) => Composition(data['ActivityReply']['text'])),
      CommentCompositionTag(id: var id) =>
        ref
            .read(repositoryProvider)
            .request(GqlQuery.commentComposition, {'id': id})
            .then((data) => Composition(_findComment(data['ThreadComment'][0]))),
    };
  }

  /// The API always returns the root comment,
  /// so we search for the target comment with DFS.
  String _findComment(Map<String, dynamic> map) {
    if (map['id'] == arg.id) {
      return map['comment'] ?? '';
    }

    for (final c in map['childComments'] ?? const []) {
      final comment = _findComment(c);
      if (comment != '') return comment;
    }

    return '';
  }

  Future<AsyncValue<Map<String, dynamic>>> save() async {
    final value = state.value;
    if (value == null) return const AsyncValue.loading();

    return AsyncValue.guard(() async {
      switch (arg) {
        case StatusActivityCompositionTag(id: var id):
          final data = await ref.read(repositoryProvider).request(GqlMutation.saveStatusActivity, {
            'id': ?id,
            'text': value.text.withParsedEmojis,
          });
          return data['SaveTextActivity'];
        case MessageActivityCompositionTag(id: var id, recipientId: var rcpId):
          final data = await ref.read(repositoryProvider).request(GqlMutation.saveMessageActivity, {
            'id': ?id,
            'text': value.text.withParsedEmojis,
            'recipientId': rcpId,
            if (value is PrivateComposition) 'isPrivate': value.isPrivate,
          });
          return data['SaveMessageActivity'];
        case ActivityReplyCompositionTag(id: var id, activityId: var actId):
          final data = await ref.read(repositoryProvider).request(GqlMutation.saveActivityReply, {
            'id': ?id,
            'text': value.text.withParsedEmojis,
            'activityId': actId,
          });
          return data['SaveActivityReply'];
        case CommentCompositionTag(
          id: var id,
          threadId: var threadId,
          parentCommentId: var parentCommentId,
        ):
          final data = await ref.read(repositoryProvider).request(GqlMutation.saveComment, {
            'id': ?id,
            'text': value.text.withParsedEmojis,
            'threadId': threadId,
            'parentCommentId': ?parentCommentId,
          });
          return data['SaveThreadComment'];
      }
    });
  }
}
