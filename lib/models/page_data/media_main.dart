import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/enums/media_list_status_enum.dart';
import 'package:otraku/models/page_data/page_object.dart';

class MediaMain extends PageObject {
  final String preferredTitle;
  final String romajiTitle;
  final String englishTitle;
  final String nativeTitle;
  final List<String> synonyms;
  final Image cover;
  final Image banner;
  final String description;
  final String format;
  final String status;
  final MediaListStatus entryStatus;
  final int nextEpisode;
  final String timeUntilAiring;
  final int parts;
  final int volumes;
  final String duration;
  final String startDate;
  final String endDate;
  final String season;
  final String averageScore;
  final String meanScore;
  final int popularity;
  final List<String> genres;
  final List<String> studios;
  final List<String> producers;
  final String source;
  final Link hashtag;
  final String countryOfOrigin;

  MediaMain({
    @required int id,
    @required Browsable browsable,
    @required bool isFavourite,
    @required int favourites,
    @required this.preferredTitle,
    @required this.romajiTitle,
    @required this.englishTitle,
    @required this.nativeTitle,
    @required this.synonyms,
    @required this.cover,
    @required this.banner,
    @required this.description,
    @required this.format,
    @required this.status,
    @required this.entryStatus,
    @required this.nextEpisode,
    @required this.timeUntilAiring,
    @required this.parts,
    @required this.volumes,
    @required this.duration,
    @required this.startDate,
    @required this.endDate,
    @required this.season,
    @required this.averageScore,
    @required this.meanScore,
    @required this.popularity,
    @required this.genres,
    @required this.studios,
    @required this.producers,
    @required this.source,
    @required this.hashtag,
    @required this.countryOfOrigin,
  }) : super(
          id: id,
          browsable: browsable,
          isFavourite: isFavourite,
          favourites: favourites,
        );
}

class Link {
  final String name;
  final String url;

  Link(this.name, this.url);
}
