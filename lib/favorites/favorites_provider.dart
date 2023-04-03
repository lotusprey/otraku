import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/character/character_models.dart';
import 'package:otraku/common/tile_item.dart';
import 'package:otraku/media/media_models.dart';
import 'package:otraku/staff/staff_models.dart';
import 'package:otraku/studio/studio_models.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/common/paged.dart';

final favoritesProvider =
    ChangeNotifierProvider.autoDispose.family<FavoritesNotifier, int>(
  (ref, userId) => FavoritesNotifier(userId),
);

class FavoritesNotifier extends ChangeNotifier {
  FavoritesNotifier(this.userId) {
    fetch();
  }

  final int userId;

  FavoriteType? _type;
  int _animeCount = 0;
  int _mangaCount = 0;
  int _characterCount = 0;
  int _staffCount = 0;
  int _studioCount = 0;
  var _anime = const AsyncValue<Paged<TileItem>>.loading();
  var _manga = const AsyncValue<Paged<TileItem>>.loading();
  var _characters = const AsyncValue<Paged<TileItem>>.loading();
  var _staff = const AsyncValue<Paged<TileItem>>.loading();
  var _studios = const AsyncValue<Paged<StudioItem>>.loading();

  int getCount(FavoriteType type) {
    _type = type;
    switch (type) {
      case FavoriteType.anime:
        return _animeCount;
      case FavoriteType.manga:
        return _mangaCount;
      case FavoriteType.characters:
        return _characterCount;
      case FavoriteType.staff:
        return _staffCount;
      case FavoriteType.studios:
        return _studioCount;
    }
  }

  AsyncValue<Paged<TileItem>> get anime => _anime;
  AsyncValue<Paged<TileItem>> get manga => _manga;
  AsyncValue<Paged<TileItem>> get characters => _characters;
  AsyncValue<Paged<TileItem>> get staff => _staff;
  AsyncValue<Paged<StudioItem>> get studios => _studios;

  Future<void> fetch() async {
    final type = _type;
    final variables = <String, dynamic>{'userId': userId};

    if (type == null) {
      variables['withAnime'] = true;
      variables['withManga'] = true;
      variables['withCharacters'] = true;
      variables['withStaff'] = true;
      variables['withStudios'] = true;
    } else if (type == FavoriteType.anime) {
      if (!(_anime.valueOrNull?.hasNext ?? true)) return;
      variables['withAnime'] = true;
      variables['page'] = _anime.valueOrNull?.next ?? 1;
    } else if (type == FavoriteType.manga) {
      if (!(_manga.valueOrNull?.hasNext ?? true)) return;
      variables['withManga'] = true;
      variables['page'] = _manga.valueOrNull?.next ?? 1;
    } else if (type == FavoriteType.characters) {
      if (!(_characters.valueOrNull?.hasNext ?? true)) return;
      variables['withCharacters'] = true;
      variables['page'] = _characters.valueOrNull?.next ?? 1;
    } else if (type == FavoriteType.staff) {
      if (!(_staff.valueOrNull?.hasNext ?? true)) return;
      variables['withStaff'] = true;
      variables['page'] = _staff.valueOrNull?.next ?? 1;
    } else {
      if (!(_studios.valueOrNull?.hasNext ?? true)) return;
      variables['withStudios'] = true;
      variables['page'] = _studios.valueOrNull?.next ?? 1;
    }

    final data = await AsyncValue.guard<Map<String, dynamic>>(() async {
      final data = await Api.get(GqlQuery.favorites, variables);
      return data['User']['favourites'];
    });

    if (type == null || type == FavoriteType.anime) {
      _anime = await AsyncValue.guard(() {
        if (data.hasError) throw data.error!;
        final map = data.value!['anime'];
        final value = _anime.valueOrNull ?? const Paged();

        if (_animeCount == 0) _animeCount = map['pageInfo']['total'] ?? 0;

        final items = <TileItem>[];
        for (final a in map['nodes']) {
          items.add(mediaItem(a));
        }

        return Future.value(value.withNext(
          items,
          map['pageInfo']['hasNextPage'] ?? false,
        ));
      });
    }

    if (type == null || type == FavoriteType.manga) {
      _manga = await AsyncValue.guard(() {
        if (data.hasError) throw data.error!;
        final map = data.value!['manga'];
        final value = _manga.valueOrNull ?? const Paged();

        if (_mangaCount == 0) _mangaCount = map['pageInfo']['total'] ?? 0;

        final items = <TileItem>[];
        for (final m in map['nodes']) {
          items.add(mediaItem(m));
        }

        return Future.value(value.withNext(
          items,
          map['pageInfo']['hasNextPage'] ?? false,
        ));
      });
    }

    if (type == null || type == FavoriteType.characters) {
      _characters = await AsyncValue.guard(() {
        if (data.hasError) throw data.error!;
        final map = data.value!['characters'];
        final value = _characters.valueOrNull ?? const Paged();

        if (_characterCount == 0) {
          _characterCount = map['pageInfo']['total'] ?? 0;
        }

        final items = <TileItem>[];
        for (final c in map['nodes']) {
          items.add(characterItem(c));
        }

        return Future.value(value.withNext(
          items,
          map['pageInfo']['hasNextPage'] ?? false,
        ));
      });
    }

    if (type == null || type == FavoriteType.staff) {
      _staff = await AsyncValue.guard(() {
        if (data.hasError) throw data.error!;
        final map = data.value!['staff'];
        final value = _staff.valueOrNull ?? const Paged();

        if (_staffCount == 0) _staffCount = map['pageInfo']['total'] ?? 0;

        final items = <TileItem>[];
        for (final s in map['nodes']) {
          items.add(staffItem(s));
        }

        return Future.value(value.withNext(
          items,
          map['pageInfo']['hasNextPage'] ?? false,
        ));
      });
    }

    if (type == null || type == FavoriteType.studios) {
      _studios = await AsyncValue.guard(() {
        if (data.hasError) throw data.error!;
        final map = data.value!['studios'];
        final value = _studios.valueOrNull ?? const Paged();

        if (_studioCount == 0) _studioCount = map['pageInfo']['total'] ?? 0;

        final items = <StudioItem>[];
        for (final s in map['nodes']) {
          items.add(StudioItem(s));
        }

        return Future.value(value.withNext(
          items,
          map['pageInfo']['hasNextPage'] ?? false,
        ));
      });
    }

    notifyListeners();
  }
}

enum FavoriteType {
  anime,
  manga,
  characters,
  staff,
  studios;

  String get text {
    switch (this) {
      case FavoriteType.anime:
        return 'Favourite Anime';
      case FavoriteType.manga:
        return 'Favourite Manga';
      case FavoriteType.characters:
        return 'Favourite Characters';
      case FavoriteType.staff:
        return 'Favourite Staff';
      case FavoriteType.studios:
        return 'Favourite Studios';
    }
  }
}
