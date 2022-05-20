import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/pagination.dart';

final reviewSortProvider = StateProvider.autoDispose.family<ReviewSort, int>(
  (ref, _) => ReviewSort.CREATED_AT_DESC,
);

final reviewsProvider =
    ChangeNotifierProvider.autoDispose.family<ReviewsNotifier, int>(
  (ref, userId) =>
      ReviewsNotifier(userId, ref.watch(reviewSortProvider(userId))),
);

class ReviewsNotifier extends ChangeNotifier {
  ReviewsNotifier(this.userId, this.sort) {
    fetch();
  }

  final int userId;
  final ReviewSort sort;

  int _count = 0;
  var _reviews = const AsyncValue<Pagination<ReviewItem>>.loading();

  int get reviewCount => _count;
  AsyncValue<Pagination<ReviewItem>> get reviews => _reviews;

  Future<void> fetch() async {
    _reviews = await AsyncValue.guard(() async {
      final value = _reviews.value ?? Pagination();

      final data = await Client.get(GqlQuery.reviews, {
        'userId': userId,
        'page': value.next,
        'sort': sort.name,
      });

      _count = data['Page']['pageInfo']?['total'] ?? 0;

      final items = <ReviewItem>[];
      for (final r in data['Page']['reviews']) items.add(ReviewItem(r));

      return value.append(
        items,
        data['Page']['pageInfo']['hasNextPage'] ?? false,
      );
    });
    notifyListeners();
  }
}

enum ReviewSort {
  CREATED_AT_DESC,
  CREATED_AT,
  RATING_DESC,
  RATING;

  String get text {
    switch (this) {
      case ReviewSort.CREATED_AT:
        return 'Oldest';
      case ReviewSort.CREATED_AT_DESC:
        return 'Newest';
      case ReviewSort.RATING:
        return 'Lowest Rated';
      case ReviewSort.RATING_DESC:
        return 'Highest Rated';
    }
  }
}

class ReviewItem {
  ReviewItem._({
    required this.id,
    required this.mediaTitle,
    required this.userName,
    required this.summary,
    required this.rating,
    required this.bannerUrl,
  });

  factory ReviewItem(Map<String, dynamic> map) => ReviewItem._(
        id: map['id'],
        mediaTitle: map['media']['title']['userPreferred'],
        userName: map['user']['name'],
        summary: map['summary'],
        rating: '${map['rating']}/${map['ratingAmount']}',
        bannerUrl: map['media']['bannerImage'],
      );

  final int id;
  final String mediaTitle;
  final String userName;
  final String summary;
  final String rating;
  final String? bannerUrl;
}
