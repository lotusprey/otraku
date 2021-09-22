import 'package:otraku/enums/explorable.dart';

class ExplorableModel {
  final int id;
  final String text1;
  final String? text2;
  final String? text3;
  final String? imageUrl;
  final Explorable explorable;

  ExplorableModel({
    required this.id,
    required this.text1,
    required this.explorable,
    this.text2,
    this.text3,
    this.imageUrl,
  });

  factory ExplorableModel.media(final Map<String, dynamic> map) =>
      ExplorableModel(
        id: map['id'],
        text1: map['title']['userPreferred'],
        imageUrl: map['coverImage']['large'],
        explorable:
            map['type'] == 'ANIME' ? Explorable.anime : Explorable.manga,
      );

  factory ExplorableModel.anime(final Map<String, dynamic> map) =>
      ExplorableModel(
        id: map['id'],
        text1: map['title']['userPreferred'],
        imageUrl: map['coverImage']['large'],
        explorable: Explorable.anime,
      );

  factory ExplorableModel.manga(final Map<String, dynamic> map) =>
      ExplorableModel(
        id: map['id'],
        text1: map['title']['userPreferred'],
        imageUrl: map['coverImage']['large'],
        explorable: Explorable.manga,
      );

  factory ExplorableModel.character(final Map<String, dynamic> map) =>
      ExplorableModel(
        id: map['id'],
        text1: map['name']['userPreferred'],
        imageUrl: map['image']['large'],
        explorable: Explorable.character,
      );

  factory ExplorableModel.staff(final Map<String, dynamic> map) =>
      ExplorableModel(
        id: map['id'],
        text1: map['name']['userPreferred'],
        imageUrl: map['image']['large'],
        explorable: Explorable.staff,
      );

  factory ExplorableModel.studio(final Map<String, dynamic> map) =>
      ExplorableModel(
        id: map['id'],
        text1: map['name'],
        explorable: Explorable.studio,
      );

  factory ExplorableModel.user(final Map<String, dynamic> map) =>
      ExplorableModel(
        id: map['id'],
        text1: map['name'],
        imageUrl: map['avatar']['large'],
        explorable: Explorable.user,
      );

  factory ExplorableModel.review(final Map<String, dynamic> map) =>
      ExplorableModel(
        id: map['id'],
        text1:
            'Review of ${map['media']['title']['userPreferred']} by ${map['user']['name']}',
        text2: map['summary'],
        text3: '${map['rating']}/${map['ratingAmount']}',
        imageUrl: map['media']['bannerImage'],
        explorable: Explorable.review,
      );
}
