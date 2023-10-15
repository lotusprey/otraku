import 'package:otraku/common/utils/api.dart';
import 'package:otraku/common/utils/extensions.dart';
import 'package:otraku/common/utils/graphql.dart';

/// Can throw. Creates/updates an activity/reply
/// and returns it as a map for deserialization.
/// A creation happens, when [id] is `null`.
Future<Map<String, dynamic>> saveComposition(Composition composition) async {
  final text = composition.text.withParsedEmojis;

  switch (composition.type) {
    case CompositionType.statusActivity:
      final data = await Api.get(
        GqlMutation.saveStatusActivity,
        {
          if (composition.id != null) 'id': composition.id,
          'text': text,
        },
      );
      return data['SaveTextActivity'];
    case CompositionType.messageActivity:
      final data = await Api.get(
        GqlMutation.saveMessageActivity,
        {
          if (composition.id != null) 'id': composition.id,
          'text': text,
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
          'text': text,
          'activityId': composition.additionalId,
        },
      );
      return data['SaveActivityReply'];
  }
}

class Composition {
  Composition._(
    this.id,
    this.type,
    this.text, [
    this.additionalId,
    this.isPrivate,
  ]) {
    /// Remove the paragraph "<p></p>" and new line "<br/>" tags from the html.
    text = text.replaceAll(_paragraphRegex, '');
  }

  Composition.status(int? id, String text)
      : this._(id, CompositionType.statusActivity, text);

  Composition.reply(int? id, String text, int activityId)
      : this._(id, CompositionType.activityReply, text, activityId);

  Composition.message(int? id, String text, int recipientId)
      : this._(
          id,
          CompositionType.messageActivity,
          text,
          recipientId,
          id == null ? false : null,
        );

  static final _paragraphRegex = RegExp(r'(\</?p\>|<br ?/>)');

  /// When creating a new item, [id] should be `null`.
  /// When updating, [id] should be the item id.
  int? id;

  final CompositionType type;
  String text;

  /// This is `null`, unless [type] is [CompositionType.messageActivity]
  /// and [id] is `null` (i.e. this is a new message).
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
