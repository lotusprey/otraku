/// Each type of composition is represented by a different tag class that
/// extends [CompositionTag]. All tags must implement equals and hash for
/// riverpod to work correctly.
sealed class CompositionTag {
  const CompositionTag({required this.id});

  final int? id;
}

class StatusActivityCompositionTag extends CompositionTag {
  const StatusActivityCompositionTag({required super.id});

  @override
  bool operator ==(Object other) =>
      other is StatusActivityCompositionTag && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class MessageActivityCompositionTag extends CompositionTag {
  const MessageActivityCompositionTag({
    required super.id,
    required this.recipientId,
  });

  final int recipientId;

  @override
  bool operator ==(Object other) =>
      other is MessageActivityCompositionTag &&
      id == other.id &&
      recipientId == other.recipientId;

  @override
  int get hashCode => Object.hash(id, recipientId);
}

class ActivityReplyCompositionTag extends CompositionTag {
  const ActivityReplyCompositionTag({
    required super.id,
    required this.activityId,
  });

  final int activityId;

  @override
  bool operator ==(Object other) =>
      other is ActivityReplyCompositionTag &&
      id == other.id &&
      activityId == other.activityId;

  @override
  int get hashCode => Object.hash(id, activityId);
}

class CommentCompositionTag extends CompositionTag {
  const CommentCompositionTag({
    required this.threadId,
    required this.parentCommentId,
  }) : super(id: null);

  const CommentCompositionTag.edit({required super.id, required this.threadId})
      : parentCommentId = null;

  final int threadId;
  final int? parentCommentId;

  @override
  bool operator ==(Object other) =>
      other is CommentCompositionTag &&
      id == other.id &&
      threadId == other.threadId &&
      parentCommentId == other.parentCommentId;

  @override
  int get hashCode => Object.hash(id, threadId, parentCommentId);
}

class Composition {
  Composition(this.text);

  String text;
}

/// Only used for new message activities, since the user can toggle visibility.
class PrivateComposition extends Composition {
  PrivateComposition(super.text, this.isPrivate);

  bool isPrivate;
}
