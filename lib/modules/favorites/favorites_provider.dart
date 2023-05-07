import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/modules/character/character_models.dart';
import 'package:otraku/common/models/tile_item.dart';
import 'package:otraku/modules/favorites/favorites_model.dart';
import 'package:otraku/modules/media/media_models.dart';
import 'package:otraku/modules/staff/staff_models.dart';
import 'package:otraku/modules/studio/studio_models.dart';
import 'package:otraku/common/utils/api.dart';
import 'package:otraku/common/utils/graphql.dart';
import 'package:otraku/common/models/paged.dart';

final favoritesProvider =
    StateNotifierProvider.autoDispose.family<FavoritesNotifier, Favorites, int>(
  (ref, userId) => FavoritesNotifier(userId),
);

class FavoritesNotifier extends StateNotifier<Favorites> {
  FavoritesNotifier(this.userId) : super(const Favorites()) {
    _fetch(null);
  }

  final int userId;

  Future<void> fetch(FavoritesTab tab) => _fetch(tab);

  Future<void> _fetch(FavoritesTab? tab) async {
    final variables = <String, dynamic>{'userId': userId};

    if (tab == null) {
      variables['withAnime'] = true;
      variables['withManga'] = true;
      variables['withCharacters'] = true;
      variables['withStaff'] = true;
      variables['withStudios'] = true;
    } else if (tab == FavoritesTab.anime) {
      if (!(state.anime.valueOrNull?.hasNext ?? true)) return;
      variables['withAnime'] = true;
      variables['page'] = state.anime.valueOrNull?.next ?? 1;
    } else if (tab == FavoritesTab.manga) {
      if (!(state.manga.valueOrNull?.hasNext ?? true)) return;
      variables['withManga'] = true;
      variables['page'] = state.manga.valueOrNull?.next ?? 1;
    } else if (tab == FavoritesTab.characters) {
      if (!(state.characters.valueOrNull?.hasNext ?? true)) return;
      variables['withCharacters'] = true;
      variables['page'] = state.characters.valueOrNull?.next ?? 1;
    } else if (tab == FavoritesTab.staff) {
      if (!(state.staff.valueOrNull?.hasNext ?? true)) return;
      variables['withStaff'] = true;
      variables['page'] = state.staff.valueOrNull?.next ?? 1;
    } else {
      if (!(state.studios.valueOrNull?.hasNext ?? true)) return;
      variables['withStudios'] = true;
      variables['page'] = state.studios.valueOrNull?.next ?? 1;
    }

    final data = await AsyncValue.guard<Map<String, dynamic>>(() async {
      final data = await Api.get(GqlQuery.favorites, variables);
      return data['User']['favourites'];
    });

    var anime = state.anime;
    var manga = state.manga;
    var characters = state.characters;
    var staff = state.staff;
    var studios = state.studios;

    if (tab == null || tab == FavoritesTab.anime) {
      anime = await AsyncValue.guard(() {
        if (data.hasError) throw data.error!;
        final map = data.value!['anime'];
        final value = anime.valueOrNull ?? const PagedWithTotal();

        final items = <TileItem>[];
        for (final a in map['nodes']) {
          items.add(mediaItem(a));
        }

        return Future.value(value.withNext(
          items,
          map['pageInfo']['hasNextPage'] ?? false,
          map['pageInfo']['total'],
        ));
      });
    }

    if (tab == null || tab == FavoritesTab.manga) {
      manga = await AsyncValue.guard(() {
        if (data.hasError) throw data.error!;
        final map = data.value!['manga'];
        final value = manga.valueOrNull ?? const PagedWithTotal();

        final items = <TileItem>[];
        for (final m in map['nodes']) {
          items.add(mediaItem(m));
        }

        return Future.value(value.withNext(
          items,
          map['pageInfo']['hasNextPage'] ?? false,
          map['pageInfo']['total'],
        ));
      });
    }

    if (tab == null || tab == FavoritesTab.characters) {
      characters = await AsyncValue.guard(() {
        if (data.hasError) throw data.error!;
        final map = data.value!['characters'];
        final value = characters.valueOrNull ?? const PagedWithTotal();

        final items = <TileItem>[];
        for (final c in map['nodes']) {
          items.add(characterItem(c));
        }

        return Future.value(value.withNext(
          items,
          map['pageInfo']['hasNextPage'] ?? false,
          map['pageInfo']['total'],
        ));
      });
    }

    if (tab == null || tab == FavoritesTab.staff) {
      staff = await AsyncValue.guard(() {
        if (data.hasError) throw data.error!;
        final map = data.value!['staff'];
        final value = staff.valueOrNull ?? const PagedWithTotal();

        final items = <TileItem>[];
        for (final s in map['nodes']) {
          items.add(staffItem(s));
        }

        return Future.value(value.withNext(
          items,
          map['pageInfo']['hasNextPage'] ?? false,
          map['pageInfo']['total'],
        ));
      });
    }

    if (tab == null || tab == FavoritesTab.studios) {
      studios = await AsyncValue.guard(() {
        if (data.hasError) throw data.error!;
        final map = data.value!['studios'];
        final value = studios.valueOrNull ?? const PagedWithTotal();

        final items = <StudioItem>[];
        for (final s in map['nodes']) {
          items.add(StudioItem(s));
        }

        return Future.value(value.withNext(
          items,
          map['pageInfo']['hasNextPage'] ?? false,
          map['pageInfo']['total'],
        ));
      });
    }

    state = Favorites(
      anime: anime,
      manga: manga,
      characters: characters,
      staff: staff,
      studios: studios,
    );
  }
}
