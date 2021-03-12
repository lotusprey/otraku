import 'package:flutter/foundation.dart';
import 'package:otraku/enums/browsable.dart';

class BrowseResultModel {
  final int id;
  final String text1;
  final String text2;
  final String text3;
  final String imageUrl;
  final Browsable browsable;

  BrowseResultModel({
    @required this.id,
    @required this.text1,
    @required this.browsable,
    this.text2,
    this.text3,
    this.imageUrl,
  });

  factory BrowseResultModel.media(final Map<String, dynamic> map) =>
      BrowseResultModel(
        id: map['id'],
        text1: map['title']['userPreferred'],
        imageUrl: map['coverImage']['large'],
        browsable: map['type'] == 'ANIME' ? Browsable.anime : Browsable.manga,
      );

  factory BrowseResultModel.anime(final Map<String, dynamic> map) =>
      BrowseResultModel(
        id: map['id'],
        text1: map['title']['userPreferred'],
        imageUrl: map['coverImage']['large'],
        browsable: Browsable.anime,
      );

  factory BrowseResultModel.manga(final Map<String, dynamic> map) =>
      BrowseResultModel(
        id: map['id'],
        text1: map['title']['userPreferred'],
        imageUrl: map['coverImage']['large'],
        browsable: Browsable.manga,
      );

  factory BrowseResultModel.character(final Map<String, dynamic> map) =>
      BrowseResultModel(
        id: map['id'],
        text1: map['name']['full'],
        imageUrl: map['image']['large'],
        browsable: Browsable.character,
      );

  factory BrowseResultModel.staff(final Map<String, dynamic> map) =>
      BrowseResultModel(
        id: map['id'],
        text1: map['name']['full'],
        imageUrl: map['image']['large'],
        browsable: Browsable.staff,
      );

  factory BrowseResultModel.studio(final Map<String, dynamic> map) =>
      BrowseResultModel(
        id: map['id'],
        text1: map['name'],
        browsable: Browsable.studio,
      );

  factory BrowseResultModel.user(final Map<String, dynamic> map) =>
      BrowseResultModel(
        id: map['id'],
        text1: map['name'],
        imageUrl: map['avatar']['large'],
        browsable: Browsable.user,
      );

  factory BrowseResultModel.review(final Map<String, dynamic> map) =>
      BrowseResultModel(
        id: map['id'],
        text1:
            'Review of ${map['media']['title']['userPreferred']} by ${map['user']['name']}',
        text2: map['summary'],
        text3: '${map['rating']}/${map['ratingAmount']}',
        imageUrl: map['media']['bannerImage'],
        browsable: Browsable.review,
      );
}
