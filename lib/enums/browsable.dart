import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

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
    Browsable.anime: FluentIcons.movies_and_tv_24_regular,
    Browsable.manga: FluentIcons.bookmark_24_regular,
    Browsable.character: FluentIcons.accessibility_24_regular,
    Browsable.staff: FluentIcons.mic_on_24_regular,
    Browsable.studio: FluentIcons.building_24_regular,
    Browsable.user: FluentIcons.person_24_regular,
    Browsable.review: Icons.rate_review_outlined,
  };

  IconData get icon => _icons[this]!;
}
