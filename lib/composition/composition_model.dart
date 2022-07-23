import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/graphql.dart';

/// Can throw. Creates/updates an activity/reply
/// and returns it as a map for deserialization.
/// A creation happens, when [id] is `null`.
Future<Map<String, dynamic>> saveComposition(Composition composition) async {
  switch (composition.type) {
    case CompositionType.statusActivity:
      final data = await Api.get(
        GqlMutation.saveStatusActivity,
        {
          if (composition.id != null) 'id': composition.id,
          'text': composition.text,
        },
      );
      return data['SaveTextActivity'];
    case CompositionType.messageActivity:
      final data = await Api.get(
        GqlMutation.saveMessageActivity,
        {
          if (composition.id != null) 'id': composition.id,
          'text': composition.text,
          'recipientId': composition.additionalId,
          'private': composition.isPrivate,
        },
      );
      return data['SaveMessageActivity'];
    case CompositionType.activityReply:
      final data = await Api.get(
        GqlMutation.saveActivityReply,
        {
          if (composition.id != null) 'id': composition.id,
          'text': composition.text,
          'activityId': composition.additionalId,
        },
      );
      return data['SaveActivityReply'];
  }
}

class Composition {
  Composition.status(this.id, this.text)
      : type = CompositionType.statusActivity;

  Composition.message(this.id, this.text, int recipientId, bool private)
      : type = CompositionType.messageActivity,
        additionalId = recipientId,
        isPrivate = private;

  Composition.reply(this.id, this.text, int activityId)
      : type = CompositionType.activityReply,
        additionalId = activityId;

  /// When creating a new item, [id] should be `null`.
  /// When updating, [id] should be the item id.
  int? id;

  CompositionType type;
  String text;

  /// This is `null`, unless [type] is [CompositionType.messageActivity]
  bool? isPrivate;

  /// Depends on the value of [type]:
  /// [CompositionType.statusActivity] - `null`
  /// [CompositionType.messageActivity] - id of the message recipient
  /// [CompositionType.activityReply] - id of the activity
  int? additionalId;
}

enum CompositionType {
  statusActivity,
  messageActivity,
  activityReply,
}
