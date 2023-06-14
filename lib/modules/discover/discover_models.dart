import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/common/models/tile_item.dart';
import 'package:otraku/common/utils/convert.dart';
import 'package:otraku/common/utils/options.dart';

enum DiscoverType {
  anime,
  manga,
  character,
  staff,
  studio,
  user,
  review;

  static const _icons = {
    DiscoverType.anime: Ionicons.film_outline,
    DiscoverType.manga: Ionicons.bookmark_outline,
    DiscoverType.character: Ionicons.man_outline,
    DiscoverType.staff: Ionicons.mic_outline,
    DiscoverType.studio: Ionicons.business_outline,
    DiscoverType.user: Ionicons.person_outline,
    DiscoverType.review: Icons.rate_review_outlined,
  };

  IconData get icon => _icons[this]!;
}

class DiscoverMediaItem extends TileItem {
  DiscoverMediaItem._({
    required super.id,
    required super.type,
    required super.title,
    required super.imageUrl,
    required this.format,
    required this.releaseStatus,
    required this.listStatus,
    required this.releaseYear,
    required this.averageScore,
    required this.popularity,
    required this.isAdult,
  });

  factory DiscoverMediaItem(Map<String, dynamic> map) => DiscoverMediaItem._(
        id: map['id'],
        type: map['type'] == 'ANIME' ? DiscoverType.anime : DiscoverType.manga,
        title: map['title']['userPreferred'],
        imageUrl: map['coverImage'][Options().imageQuality.value],
        format: Convert.clarifyEnum(map['format']),
        releaseStatus: Convert.clarifyEnum(map['status']),
        listStatus: Convert.clarifyEnum(map['mediaListEntry']?['status']),
        releaseYear: map['startDate']?['year'],
        averageScore: map['averageScore'] ?? 0,
        popularity: map['popularity'] ?? 0,
        isAdult: map['isAdult'] ?? false,
      );

  final String? format;
  final String? releaseStatus;
  final String? listStatus;
  final int? releaseYear;
  final int averageScore;
  final int popularity;
  final bool isAdult;
}
