import 'package:otraku/feature/comment/comment_model.dart';
import 'package:otraku/feature/forum/forum_model.dart';
import 'package:otraku/feature/user/user_item_model.dart';
import 'package:otraku/util/paged.dart';

class Social {
  const Social({
    this.following = const PagedWithTotal(),
    this.followers = const PagedWithTotal(),
    this.threads = const PagedWithTotal(),
    this.comments = const PagedWithTotal(),
  });

  final PagedWithTotal<UserItem> following;
  final PagedWithTotal<UserItem> followers;
  final PagedWithTotal<ThreadItem> threads;
  final PagedWithTotal<Comment> comments;

  int getCount(SocialTab tab) => switch (tab) {
    .following => following.total,
    .followers => followers.total,
    .threads => threads.total,
    .comments => comments.total,
  };
}

enum SocialTab {
  following,
  followers,
  threads,
  comments;

  String get title => switch (this) {
    .following => 'Following',
    .followers => 'Followers',
    .threads => 'Threads',
    .comments => 'Comments',
  };
}
