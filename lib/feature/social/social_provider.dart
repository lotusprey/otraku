import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/comment/comment_model.dart';
import 'package:otraku/feature/forum/forum_model.dart';
import 'package:otraku/feature/social/social_model.dart';
import 'package:otraku/feature/user/user_item_model.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';
import 'package:otraku/util/graphql.dart';

final socialProvider =
    AsyncNotifierProvider.autoDispose.family<SocialNotifier, Social, int>(
  SocialNotifier.new,
);

class SocialNotifier extends AutoDisposeFamilyAsyncNotifier<Social, int> {
  @override
  FutureOr<Social> build(int arg) => _fetch(const Social(), null);

  Future<void> fetch(SocialTab tab) async {
    final oldState = state.valueOrNull ?? const Social();
    switch (tab) {
      case SocialTab.following:
        if (!oldState.following.hasNext) return;
      case SocialTab.followers:
        if (!oldState.followers.hasNext) return;
      case SocialTab.threads:
        if (!oldState.threads.hasNext) return;
      case SocialTab.comments:
        if (!oldState.comments.hasNext) return;
    }
    state = await AsyncValue.guard(() => _fetch(oldState, tab));
  }

  Future<Social> _fetch(Social oldState, SocialTab? tab) async {
    final variables = <String, dynamic>{'userId': arg};

    switch (tab) {
      case null:
        variables['withFollowing'] = true;
        variables['withFollowers'] = true;
        variables['withThreads'] = true;
        variables['withComments'] = true;
        break;
      case SocialTab.following:
        variables['withFollowing'] = true;
        variables['page'] = oldState.following.next;
        break;
      case SocialTab.followers:
        variables['withFollowers'] = true;
        variables['page'] = oldState.followers.next;
        break;
      case SocialTab.threads:
        variables['withThreads'] = true;
        variables['page'] = oldState.threads.next;
        break;
      case SocialTab.comments:
        variables['withComments'] = true;
        variables['page'] = oldState.comments.next;
        break;
    }

    final data = await ref.read(repositoryProvider).request(
          GqlQuery.social,
          variables,
        );

    var following = oldState.following;
    var followers = oldState.followers;
    var threads = oldState.threads;
    var comments = oldState.comments;

    if (tab == null || tab == SocialTab.following) {
      final map = data['following'];
      final items = <UserItem>[];
      for (final u in map['following']) {
        items.add(UserItem(u));
      }

      following = following.withNext(
        items,
        map['pageInfo']['hasNextPage'] ?? false,
        map['pageInfo']['total'],
      );
    }

    if (tab == null || tab == SocialTab.followers) {
      final map = data['followers'];
      final items = <UserItem>[];
      for (final u in map['followers']) {
        items.add(UserItem(u));
      }

      followers = followers.withNext(
        items,
        map['pageInfo']['hasNextPage'] ?? false,
        map['pageInfo']['total'],
      );
    }

    if (tab == null || tab == SocialTab.threads) {
      final map = data['threads'];
      final items = <ThreadItem>[];
      for (final u in map['threads']) {
        items.add(ThreadItem(u));
      }

      threads = threads.withNext(
        items,
        map['pageInfo']['hasNextPage'] ?? false,
        map['pageInfo']['total'],
      );
    }

    if (tab == null || tab == SocialTab.comments) {
      final map = data['comments'];
      final items = <Comment>[];
      for (final u in map['threadComments']) {
        items.add(Comment(u));
      }

      comments = comments.withNext(
        items,
        map['pageInfo']['hasNextPage'] ?? false,
        map['pageInfo']['total'],
      );
    }

    return Social(
      following: following,
      followers: followers,
      threads: threads,
      comments: comments,
    );
  }
}
