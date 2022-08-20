import 'package:otraku/discover/discover_models.dart';
import 'package:otraku/utils/settings.dart';

class RecommendedModel {
  RecommendedModel._({
    required this.id,
    required this.rating,
    required this.userRating,
    required this.title,
    required this.type,
    required this.imageUrl,
  });

  factory RecommendedModel(Map<String, dynamic> map) {
    bool? userRating;
    if (map['userRating'] == 'RATE_UP') userRating = true;
    if (map['userRating'] == 'RATE_DOWN') userRating = false;

    return RecommendedModel._(
      id: map['mediaRecommendation']['id'],
      rating: map['rating'] ?? 0,
      userRating: userRating,
      title: map['mediaRecommendation']['title']['userPreferred'],
      type: map['type'] == 'ANIME' ? DiscoverType.anime : DiscoverType.manga,
      imageUrl: map['mediaRecommendation']['coverImage']
          [Settings().imageQuality],
    );
  }

  final int id;
  int rating;
  bool? userRating;
  final String title;
  final DiscoverType type;
  final String? imageUrl;
}
