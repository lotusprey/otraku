import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

enum Explorable {
  anime,
  manga,
  character,
  staff,
  studio,
  user,
  review,
}

extension BrowsableExtension on Explorable {
  static const _icons = {
    Explorable.anime: Ionicons.film_outline,
    Explorable.manga: Ionicons.bookmark_outline,
    Explorable.character: Ionicons.man_outline,
    Explorable.staff: Ionicons.mic_outline,
    Explorable.studio: Ionicons.business_outline,
    Explorable.user: Ionicons.person_outline,
    Explorable.review: Icons.rate_review_outlined,
  };

  IconData get icon => _icons[this]!;
}
