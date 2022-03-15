import 'package:otraku/constants/explorable.dart';

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
      type: map['type'] == 'ANIME' ? Explorable.anime : Explorable.manga,
      imageUrl: map['mediaRecommendation']['coverImage']['extraLarge'],
    );
  }

  final int id;
  final int rating;
  bool? userRating;
  final String title;
  final Explorable type;
  final String? imageUrl;
}
