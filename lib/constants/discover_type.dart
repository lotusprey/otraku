import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

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
