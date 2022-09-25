import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/settings.dart';

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

class DiscoverMediaItem {
  DiscoverMediaItem._({
    required this.mediaId,
    required this.title,
    required this.imageUrl,
    required this.format,
    required this.releaseStatus,
    required this.listStatus,
    required this.releaseYear,
    required this.averageScore,
    required this.popularity,
    required this.isAdult,
  });

  factory DiscoverMediaItem(Map<String, dynamic> map) => DiscoverMediaItem._(
        mediaId: map['id'],
        title: map['title']['userPreferred'],
        imageUrl: map['coverImage'][Settings().imageQuality],
        format: Convert.clarifyEnum(map['format']),
        releaseStatus: Convert.clarifyEnum(map['status']),
        listStatus: Convert.clarifyEnum(map['mediaListEntry']?['status']),
        releaseYear: map['startDate']?['year'],
        averageScore: map['averageScore'] ?? 0,
        popularity: map['popularity'] ?? 0,
        isAdult: map['isAdult'] ?? false,
      );

  final int mediaId;
  final String title;
  final String imageUrl;
  final String? format;
  final String? releaseStatus;
  final String? listStatus;
  final int? releaseYear;
  final int averageScore;
  final int popularity;
  final bool isAdult;
}
