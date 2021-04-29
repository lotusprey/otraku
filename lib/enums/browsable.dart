import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

enum Browsable {
  anime,
  manga,
  character,
  staff,
  studio,
  user,
  review,
}

extension BrowsableExtension on Browsable {
  static const _icons = {
    Browsable.anime: Ionicons.film_outline,
    Browsable.manga: Ionicons.bookmark_outline,
    Browsable.character: Ionicons.man_outline,
    Browsable.staff: Ionicons.mic_outline,
    Browsable.studio: Ionicons.business_outline,
    Browsable.user: Ionicons.person_outline,
    Browsable.review: Icons.rate_review_outlined,
  };

  IconData get icon => _icons[this]!;
}
