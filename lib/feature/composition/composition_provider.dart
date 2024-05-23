import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/util/extensions.dart';
import 'package:otraku/util/graphql.dart';
import 'package:otraku/feature/composition/composition_model.dart';
import 'package:otraku/feature/viewer/api.dart';

final compositionProvider = AsyncNotifierProvider.autoDispose
    .family<CompositionNotifier, Composition, CompositionTag>(
  CompositionNotifier.new,
);

class CompositionNotifier
    extends AutoDisposeFamilyAsyncNotifier<Composition, CompositionTag> {
  @override
  FutureOr<Composition> build(arg) {
    if (arg.id == null) {
      return switch (arg) {
        MessageActivityCompositionTag _ => PrivateComposition('', false),
        _ => Composition(''),
      };
    }

    return switch (arg) {
      StatusActivityCompositionTag(id: var id) =>
        Api.get(GqlQuery.activityComposition, {'id': id}).then(
          (data) => Composition(data['Activity']['text']),
        ),
      MessageActivityCompositionTag(id: var id) =>
        Api.get(GqlQuery.activityComposition, {'id': id}).then(
          (data) => Composition(data['Activity']['message']),
        ),
      ActivityReplyCompositionTag(id: var id) =>
        Api.get(GqlQuery.activityReplyComposition, {'id': id}).then(
          (data) => Composition(data['ActivityReply']['text']),
        ),
    };
  }

  Future<AsyncValue<Map<String, dynamic>>> save() async {
    final value = state.valueOrNull;
    if (value == null) return const AsyncValue.loading();

    return AsyncValue.guard(() async {
      switch (arg) {
        case StatusActivityCompositionTag(id: var id):
          final data = await Api.get(GqlMutation.saveStatusActivity, {
            if (id != null) 'id': id,
            'text': value.text.withParsedEmojis,
          });
          return data['SaveTextActivity'];
        case MessageActivityCompositionTag(id: var id, recipientId: var rcpId):
          final data = await Api.get(GqlMutation.saveMessageActivity, {
            if (id != null) 'id': id,
            'text': value.text.withParsedEmojis,
            'recipientId': rcpId,
            if (value is PrivateComposition) 'isPrivate': value.isPrivate,
          });
          return data['SaveMessageActivity'];
        case ActivityReplyCompositionTag(id: var id, activityId: var actId):
          final data = await Api.get(GqlMutation.saveActivityReply, {
            if (id != null) 'id': id,
            'text': value.text.withParsedEmojis,
            'activityId': actId,
          });
          return data['SaveActivityReply'];
      }
    });
  }
}
