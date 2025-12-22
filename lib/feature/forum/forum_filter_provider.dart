import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/forum/forum_filter_model.dart';

final forumFilterProvider = NotifierProvider.autoDispose<ForumFilterNotifier, ForumFilter>(
  ForumFilterNotifier.new,
);

class ForumFilterNotifier extends Notifier<ForumFilter> {
  @override
  ForumFilter build() =>
      const ForumFilter(search: '', category: null, isSubscribed: false, sort: .lastRepliedTo);

  void update(ForumFilter Function(ForumFilter) callback) => state = callback(state);
}
