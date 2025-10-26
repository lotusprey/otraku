import 'package:otraku/extension/iterable_extension.dart';

class ForumFilter {
  const ForumFilter({
    required this.search,
    required this.category,
    required this.isSubscribed,
    required this.sort,
  });

  final String search;
  final ThreadCategory? category;
  final bool isSubscribed;
  final ThreadSort sort;

  ForumFilter copyWith({
    String? search,
    (ThreadCategory?,)? category,
    bool? isSubscribed,
    ThreadSort? sort,
  }) =>
      ForumFilter(
        search: search ?? this.search,
        category: category == null ? this.category : category.$1,
        isSubscribed: isSubscribed ?? this.isSubscribed,
        sort: sort ?? this.sort,
      );

  Map<String, dynamic> toGraphQlVariables() => {
        if (search.isNotEmpty) 'search': search,
        if (isSubscribed) 'subscribed': true,
        if (category != null) 'categoryId': category!.id,
        if (search.isEmpty) 'sort': sort.value else 'sort': ThreadSort.lastCreated.value,
      };
}

enum ThreadCategory {
  general('General', 7),
  anime('Anime', 1),
  manga('Manga', 2),
  lightNovels('Light Novels', 3),
  visualNovels('Visual Novels', 4),
  gaming('Gaming', 10),
  music('Music', 9),
  news('News', 8),
  releases('Release Discussions', 5),
  recommendations('Recommendations', 15),
  forumGames('Forum Games', 16),
  miscellaneous('Misc', 17),
  announcements('Site Announcements', 13),
  feedback('Site Feedback', 11),
  bugs('Bug Reports', 12),
  apps('AniList Apps', 18);

  const ThreadCategory(this.label, this.id);

  final String label;
  final int id;

  static ThreadCategory? from(String? label) =>
      ThreadCategory.values.firstWhereOrNull((v) => v.label == label);
}

enum ThreadSort {
  pinned('Pinned', 'IS_STICKY'),
  firstCreated('First Created', 'CREATED_AT'),
  lastCreated('Last Created', 'CREATED_AT_DESC'),
  lastRepliedTo('Last Replied To', 'REPLIED_AT_DESC');

  const ThreadSort(this.label, this.value);

  final String label;
  final String value;
}
