import 'package:otraku/constants/discover_type.dart';
import 'package:otraku/utils/settings.dart';

class DiscoverModel {
  final int id;
  final String text1;
  final String? text2;
  final String? text3;
  final String? imageUrl;
  final DiscoverType discoverType;

  DiscoverModel({
    required this.id,
    required this.text1,
    required this.discoverType,
    this.text2,
    this.text3,
    this.imageUrl,
  });

  factory DiscoverModel.media(final Map<String, dynamic> map) => DiscoverModel(
        id: map['id'],
        text1: map['title']['userPreferred'],
        imageUrl: map['coverImage'][Settings().imageQuality],
        discoverType:
            map['type'] == 'ANIME' ? DiscoverType.anime : DiscoverType.manga,
      );

  factory DiscoverModel.anime(final Map<String, dynamic> map) => DiscoverModel(
        id: map['id'],
        text1: map['title']['userPreferred'],
        imageUrl: map['coverImage'][Settings().imageQuality],
        discoverType: DiscoverType.anime,
      );

  factory DiscoverModel.manga(final Map<String, dynamic> map) => DiscoverModel(
        id: map['id'],
        text1: map['title']['userPreferred'],
        imageUrl: map['coverImage'][Settings().imageQuality],
        discoverType: DiscoverType.manga,
      );

  factory DiscoverModel.character(final Map<String, dynamic> map) =>
      DiscoverModel(
        id: map['id'],
        text1: map['name']['userPreferred'],
        imageUrl: map['image']['large'],
        discoverType: DiscoverType.character,
      );

  factory DiscoverModel.staff(final Map<String, dynamic> map) => DiscoverModel(
        id: map['id'],
        text1: map['name']['userPreferred'],
        imageUrl: map['image']['large'],
        discoverType: DiscoverType.staff,
      );

  factory DiscoverModel.studio(final Map<String, dynamic> map) => DiscoverModel(
        id: map['id'],
        text1: map['name'],
        discoverType: DiscoverType.studio,
      );

  factory DiscoverModel.user(final Map<String, dynamic> map) => DiscoverModel(
        id: map['id'],
        text1: map['name'],
        imageUrl: map['avatar']['large'],
        discoverType: DiscoverType.user,
      );

  factory DiscoverModel.review(final Map<String, dynamic> map) => DiscoverModel(
        id: map['id'],
        text1:
            'Review of ${map['media']['title']['userPreferred']} by ${map['user']['name']}',
        text2: map['summary'],
        text3: '${map['rating']}/${map['ratingAmount']}',
        imageUrl: map['media']['bannerImage'],
        discoverType: DiscoverType.review,
      );
}
