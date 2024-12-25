import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/feature/favorites/favorites_model.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';
import 'package:otraku/util/graphql.dart';

final favoritesProvider =
    AsyncNotifierProvider.autoDispose.family<FavoritesNotifier, Favorites, int>(
  FavoritesNotifier.new,
);

class FavoritesNotifier extends AutoDisposeFamilyAsyncNotifier<Favorites, int> {
  @override
  FutureOr<Favorites> build(int arg) => _fetch(const Favorites(), null);

  Future<void> fetch(FavoritesTab tab) async {
    final oldState = state.valueOrNull ?? const Favorites();
    switch (tab) {
      case FavoritesTab.anime:
        if (!oldState.anime.hasNext) return;
      case FavoritesTab.manga:
        if (!oldState.manga.hasNext) return;
      case FavoritesTab.characters:
        if (!oldState.characters.hasNext) return;
      case FavoritesTab.staff:
        if (!oldState.staff.hasNext) return;
      case FavoritesTab.studios:
        if (!oldState.studios.hasNext) return;
    }
    state = await AsyncValue.guard(() => _fetch(oldState, tab));
  }

  Future<Favorites> _fetch(Favorites oldState, FavoritesTab? tab) async {
    final edit = oldState.edit;
    final variables = <String, dynamic>{'userId': arg};

    if (tab == null) {
      variables['withAnime'] = true;
      variables['withManga'] = true;
      variables['withCharacters'] = true;
      variables['withStaff'] = true;
      variables['withStudios'] = true;
    } else if (tab == FavoritesTab.anime) {
      variables['withAnime'] = true;
      variables['page'] = oldState.anime.next;
    } else if (tab == FavoritesTab.manga) {
      variables['withManga'] = true;
      variables['page'] = oldState.manga.next;
    } else if (tab == FavoritesTab.characters) {
      variables['withCharacters'] = true;
      variables['page'] = oldState.characters.next;
    } else if (tab == FavoritesTab.staff) {
      variables['withStaff'] = true;
      variables['page'] = oldState.staff.next;
    } else {
      variables['withStudios'] = true;
      variables['page'] = oldState.studios.next;
    }

    var data = await ref
        .read(repositoryProvider)
        .request(GqlQuery.favorites, variables);
    data = data['User']['favourites'];

    final imageQuality = ref.read(persistenceProvider).options.imageQuality;

    var anime = oldState.anime;
    var manga = oldState.manga;
    var characters = oldState.characters;
    var staff = oldState.staff;
    var studios = oldState.studios;

    if (tab == null || tab == FavoritesTab.anime) {
      final map = data['anime'];
      final items = <FavoriteItem>[];
      for (final a in map['nodes']) {
        items.add(FavoriteItem.media(a, imageQuality));
      }

      anime = anime.withNext(
        items,
        map['pageInfo']['hasNextPage'] ?? false,
        map['pageInfo']['total'],
      );

      if (edit?.editedTab == FavoritesTab.anime) {
        edit!.oldItems.addAll(items);
      }
    }

    if (tab == null || tab == FavoritesTab.manga) {
      final map = data['manga'];
      final items = <FavoriteItem>[];
      for (final m in map['nodes']) {
        items.add(FavoriteItem.media(m, imageQuality));
      }

      manga = manga.withNext(
        items,
        map['pageInfo']['hasNextPage'] ?? false,
        map['pageInfo']['total'],
      );

      if (edit?.editedTab == FavoritesTab.manga) {
        edit!.oldItems.addAll(items);
      }
    }

    if (tab == null || tab == FavoritesTab.characters) {
      final map = data['characters'];
      final items = <FavoriteItem>[];
      for (final c in map['nodes']) {
        items.add(FavoriteItem.character(c));
      }

      characters = characters.withNext(
        items,
        map['pageInfo']['hasNextPage'] ?? false,
        map['pageInfo']['total'],
      );

      if (edit?.editedTab == FavoritesTab.characters) {
        edit!.oldItems.addAll(items);
      }
    }

    if (tab == null || tab == FavoritesTab.staff) {
      final map = data['staff'];
      final items = <FavoriteItem>[];
      for (final s in map['nodes']) {
        items.add(FavoriteItem.staff(s));
      }

      staff = staff.withNext(
        items,
        map['pageInfo']['hasNextPage'] ?? false,
        map['pageInfo']['total'],
      );

      if (edit?.editedTab == FavoritesTab.staff) {
        edit!.oldItems.addAll(items);
      }
    }

    if (tab == null || tab == FavoritesTab.studios) {
      final map = data['studios'];
      final items = <FavoriteItem>[];
      for (final s in map['nodes']) {
        items.add(FavoriteItem.studio(s));
      }

      studios = studios.withNext(
        items,
        map['pageInfo']['hasNextPage'] ?? false,
        map['pageInfo']['total'],
      );

      if (edit?.editedTab == FavoritesTab.studios) {
        edit!.oldItems.addAll(items);
      }
    }

    return Favorites(
      anime: anime,
      manga: manga,
      characters: characters,
      staff: staff,
      studios: studios,
      edit: edit,
    );
  }

  void startEdit(FavoritesTab tab) {
    final value = state.valueOrNull;
    if (value == null) return;

    final edit = FavoritesEdit(
      tab,
      switch (tab) {
        FavoritesTab.anime => [...value.anime.items],
        FavoritesTab.manga => [...value.manga.items],
        FavoritesTab.characters => [...value.characters.items],
        FavoritesTab.staff => [...value.staff.items],
        FavoritesTab.studios => [...value.studios.items],
      },
    );

    state = AsyncValue.data(value.withEdit(edit));
  }

  void cancelEdit() {
    final value = state.valueOrNull;
    if (value == null) return;

    final edit = value.edit;
    if (edit == null) return;

    switch (edit.editedTab) {
      case FavoritesTab.anime:
        value.anime.items.clear();
        value.anime.items.addAll(edit.oldItems);
      case FavoritesTab.manga:
        value.manga.items.clear();
        value.manga.items.addAll(edit.oldItems);
      case FavoritesTab.characters:
        value.characters.items.clear();
        value.characters.items.addAll(edit.oldItems);
      case FavoritesTab.staff:
        value.staff.items.clear();
        value.staff.items.addAll(edit.oldItems);
      case FavoritesTab.studios:
        value.studios.items.clear();
        value.studios.items.addAll(edit.oldItems);
    }

    state = AsyncValue.data(value.withEdit(null));
  }

  Future<Object?> saveEdit() async {
    final value = state.valueOrNull;
    if (value == null) return null;

    final edit = value.edit;
    if (edit == null) return null;

    state = AsyncValue.data(value.withEdit(null));

    String idsVariableKey;
    String indexesVariableKey;
    List<FavoriteItem> items;
    switch (edit.editedTab) {
      case FavoritesTab.anime:
        idsVariableKey = 'animeIds';
        indexesVariableKey = 'animeOrder';
        items = value.anime.items;
      case FavoritesTab.manga:
        idsVariableKey = 'mangaIds';
        indexesVariableKey = 'mangaOrder';
        items = value.manga.items;
      case FavoritesTab.characters:
        idsVariableKey = 'characterIds';
        indexesVariableKey = 'characterOrder';
        items = value.characters.items;
      case FavoritesTab.staff:
        idsVariableKey = 'staffIds';
        indexesVariableKey = 'staffOrder';
        items = value.staff.items;
      case FavoritesTab.studios:
        idsVariableKey = 'studioIds';
        indexesVariableKey = 'studioOrder';
        items = value.studios.items;
    }

    final ids = items.map((e) => e.id).toList();
    final indexes = List.generate(items.length, (i) => i + 1, growable: false);

    try {
      await ref.read(repositoryProvider).request(
        GqlMutation.reorderFavorites,
        {idsVariableKey: ids, indexesVariableKey: indexes},
      );

      return null;
    } catch (e) {
      cancelEdit();
      return e;
    }
  }
}
