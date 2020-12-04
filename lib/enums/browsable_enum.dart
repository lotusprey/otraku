import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';

enum Browsable {
  anime,
  manga,
  characters,
  staff,
  studios,
}

extension BrowsableExtension on Browsable {
  static const _icons = {
    Browsable.anime: FluentSystemIcons.ic_fluent_movies_and_tv_regular,
    Browsable.manga: FluentSystemIcons.ic_fluent_bookmark_regular,
    Browsable.characters: FluentSystemIcons.ic_fluent_accessibility_regular,
    Browsable.staff: FluentSystemIcons.ic_fluent_mic_on_regular,
    Browsable.studios: FluentSystemIcons.ic_fluent_building_regular,
  };

  IconData get icon => _icons[this];
}
