import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
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
    Browsable.anime: FluentSystemIcons.ic_fluent_movies_and_tv_regular,
    Browsable.manga: FluentSystemIcons.ic_fluent_bookmark_regular,
    Browsable.character: FluentSystemIcons.ic_fluent_accessibility_regular,
    Browsable.staff: FluentSystemIcons.ic_fluent_mic_on_regular,
    Browsable.studio: FluentSystemIcons.ic_fluent_building_regular,
    Browsable.user: FluentSystemIcons.ic_fluent_person_regular,
    Browsable.review: Icons.rate_review_outlined,
  };

  IconData get icon => _icons[this];
}
