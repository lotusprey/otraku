import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/extension/future_extension.dart';
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

  Future<void> fetch(FavoritesType type) async {
    final oldState = state.valueOrNull ?? const Favorites();
    switch (type) {
      case FavoritesType.anime:
        if (!oldState.anime.hasNext) return;
      case FavoritesType.manga:
        if (!oldState.manga.hasNext) return;
      case FavoritesType.characters:
        if (!oldState.characters.hasNext) return;
      case FavoritesType.staff:
        if (!oldState.staff.hasNext) return;
      case FavoritesType.studios:
        if (!oldState.studios.hasNext) return;
    }
    state = await AsyncValue.guard(() => _fetch(oldState, type));
  }

  Future<Favorites> _fetch(Favorites oldState, FavoritesType? type) async {
    final edit = oldState.edit;
    final variables = <String, dynamic>{'userId': arg};

    if (type == null) {
      variables['withAnime'] = true;
      variables['withManga'] = true;
      variables['withCharacters'] = true;
      variables['withStaff'] = true;
      variables['withStudios'] = true;
    } else if (type == FavoritesType.anime) {
      variables['withAnime'] = true;
      variables['page'] = oldState.anime.next;
    } else if (type == FavoritesType.manga) {
      variables['withManga'] = true;
      variables['page'] = oldState.manga.next;
    } else if (type == FavoritesType.characters) {
      variables['withCharacters'] = true;
      variables['page'] = oldState.characters.next;
    } else if (type == FavoritesType.staff) {
      variables['withStaff'] = true;
      variables['page'] = oldState.staff.next;
    } else {
      variables['withStudios'] = true;
      variables['page'] = oldState.studios.next;
    }

    var data = await ref.read(repositoryProvider).request(GqlQuery.favorites, variables);
    data = data['User']['favourites'];

    final imageQuality = ref.read(persistenceProvider).options.imageQuality;

    var anime = oldState.anime;
    var manga = oldState.manga;
    var characters = oldState.characters;
    var staff = oldState.staff;
    var studios = oldState.studios;

    if (type == null || type == FavoritesType.anime) {
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

      if (edit?.editedType == FavoritesType.anime) {
        edit!.oldItems.addAll(items);
      }
    }

    if (type == null || type == FavoritesType.manga) {
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

      if (edit?.editedType == FavoritesType.manga) {
        edit!.oldItems.addAll(items);
      }
    }

    if (type == null || type == FavoritesType.characters) {
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

      if (edit?.editedType == FavoritesType.characters) {
        edit!.oldItems.addAll(items);
      }
    }

    if (type == null || type == FavoritesType.staff) {
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

      if (edit?.editedType == FavoritesType.staff) {
        edit!.oldItems.addAll(items);
      }
    }

    if (type == null || type == FavoritesType.studios) {
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

      if (edit?.editedType == FavoritesType.studios) {
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

  void startEdit(FavoritesType type) {
    final value = state.valueOrNull;
    if (value == null) return;

    final edit = FavoritesEdit(
      type,
      switch (type) {
        FavoritesType.anime => [...value.anime.items],
        FavoritesType.manga => [...value.manga.items],
        FavoritesType.characters => [...value.characters.items],
        FavoritesType.staff => [...value.staff.items],
        FavoritesType.studios => [...value.studios.items],
      },
    );

    state = AsyncValue.data(value.withEdit(edit));
  }

  void cancelEdit() {
    final value = state.valueOrNull;
    if (value == null) return;

    final edit = value.edit;
    if (edit == null) return;

    switch (edit.editedType) {
      case FavoritesType.anime:
        value.anime.items.clear();
        value.anime.items.addAll(edit.oldItems);
      case FavoritesType.manga:
        value.manga.items.clear();
        value.manga.items.addAll(edit.oldItems);
      case FavoritesType.characters:
        value.characters.items.clear();
        value.characters.items.addAll(edit.oldItems);
      case FavoritesType.staff:
        value.staff.items.clear();
        value.staff.items.addAll(edit.oldItems);
      case FavoritesType.studios:
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
    switch (edit.editedType) {
      case FavoritesType.anime:
        idsVariableKey = 'animeIds';
        indexesVariableKey = 'animeOrder';
        items = value.anime.items;
      case FavoritesType.manga:
        idsVariableKey = 'mangaIds';
        indexesVariableKey = 'mangaOrder';
        items = value.manga.items;
      case FavoritesType.characters:
        idsVariableKey = 'characterIds';
        indexesVariableKey = 'characterOrder';
        items = value.characters.items;
      case FavoritesType.staff:
        idsVariableKey = 'staffIds';
        indexesVariableKey = 'staffOrder';
        items = value.staff.items;
      case FavoritesType.studios:
        idsVariableKey = 'studioIds';
        indexesVariableKey = 'studioOrder';
        items = value.studios.items;
    }

    final ids = items.map((e) => e.id).toList();
    final indexes = List.generate(items.length, (i) => i + 1, growable: false);

    final err = await ref.read(repositoryProvider).request(
      GqlMutation.reorderFavorites,
      {idsVariableKey: ids, indexesVariableKey: indexes},
    ).getErrorOrNull();

    if (err != null) cancelEdit();
    return err;
  }

  Future<Object?> toggleFavorite(int id) async {
    final edit = state.valueOrNull?.edit;
    if (edit == null) return null;

    final typeKey = switch (edit.editedType) {
      FavoritesType.anime => 'anime',
      FavoritesType.manga => 'manga',
      FavoritesType.characters => 'character',
      FavoritesType.staff => 'staff',
      FavoritesType.studios => 'studio',
    };

    return ref
        .read(repositoryProvider)
        .request(GqlMutation.toggleFavorite, {typeKey: id}).getErrorOrNull();
  }
}
