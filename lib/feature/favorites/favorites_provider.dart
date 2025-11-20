import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/extension/future_extension.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/feature/favorites/favorites_model.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';
import 'package:otraku/util/graphql.dart';

final favoritesProvider = AsyncNotifierProvider.autoDispose
    .family<FavoritesNotifier, Favorites, int>(FavoritesNotifier.new);

class FavoritesNotifier extends AsyncNotifier<Favorites> {
  FavoritesNotifier(this.arg);

  final int arg;

  @override
  FutureOr<Favorites> build() => _fetch(const Favorites(), null);

  Future<void> fetch(FavoritesType type) async {
    final oldState = state.value ?? const Favorites();
    switch (type) {
      case .anime:
        if (!oldState.anime.hasNext) return;
      case .manga:
        if (!oldState.manga.hasNext) return;
      case .characters:
        if (!oldState.characters.hasNext) return;
      case .staff:
        if (!oldState.staff.hasNext) return;
      case .studios:
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
    } else if (type == .anime) {
      variables['withAnime'] = true;
      variables['page'] = oldState.anime.next;
    } else if (type == .manga) {
      variables['withManga'] = true;
      variables['page'] = oldState.manga.next;
    } else if (type == .characters) {
      variables['withCharacters'] = true;
      variables['page'] = oldState.characters.next;
    } else if (type == .staff) {
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

    if (type == null || type == .anime) {
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

      if (edit?.editedType == .anime) {
        edit!.oldItems.addAll(items);
      }
    }

    if (type == null || type == .manga) {
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

      if (edit?.editedType == .manga) {
        edit!.oldItems.addAll(items);
      }
    }

    if (type == null || type == .characters) {
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

      if (edit?.editedType == .characters) {
        edit!.oldItems.addAll(items);
      }
    }

    if (type == null || type == .staff) {
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

      if (edit?.editedType == .staff) {
        edit!.oldItems.addAll(items);
      }
    }

    if (type == null || type == .studios) {
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

      if (edit?.editedType == .studios) {
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
    final value = state.value;
    if (value == null) return;

    final edit = FavoritesEdit(type, switch (type) {
      .anime => [...value.anime.items],
      .manga => [...value.manga.items],
      .characters => [...value.characters.items],
      .staff => [...value.staff.items],
      .studios => [...value.studios.items],
    });

    state = AsyncValue.data(value.withEdit(edit));
  }

  void cancelEdit() {
    final value = state.value;
    if (value == null) return;

    final edit = value.edit;
    if (edit == null) return;

    switch (edit.editedType) {
      case .anime:
        value.anime.items.clear();
        value.anime.items.addAll(edit.oldItems);
      case .manga:
        value.manga.items.clear();
        value.manga.items.addAll(edit.oldItems);
      case .characters:
        value.characters.items.clear();
        value.characters.items.addAll(edit.oldItems);
      case .staff:
        value.staff.items.clear();
        value.staff.items.addAll(edit.oldItems);
      case .studios:
        value.studios.items.clear();
        value.studios.items.addAll(edit.oldItems);
    }

    state = AsyncValue.data(value.withEdit(null));
  }

  Future<Object?> saveEdit() async {
    final value = state.value;
    if (value == null) return null;

    final edit = value.edit;
    if (edit == null) return null;

    state = AsyncValue.data(value.withEdit(null));

    String idsVariableKey;
    String indexesVariableKey;
    List<FavoriteItem> items;
    switch (edit.editedType) {
      case .anime:
        idsVariableKey = 'animeIds';
        indexesVariableKey = 'animeOrder';
        items = value.anime.items;
      case .manga:
        idsVariableKey = 'mangaIds';
        indexesVariableKey = 'mangaOrder';
        items = value.manga.items;
      case .characters:
        idsVariableKey = 'characterIds';
        indexesVariableKey = 'characterOrder';
        items = value.characters.items;
      case .staff:
        idsVariableKey = 'staffIds';
        indexesVariableKey = 'staffOrder';
        items = value.staff.items;
      case .studios:
        idsVariableKey = 'studioIds';
        indexesVariableKey = 'studioOrder';
        items = value.studios.items;
    }

    final ids = items.map((e) => e.id).toList();
    final indexes = List.generate(items.length, (i) => i + 1, growable: false);

    final err = await ref.read(repositoryProvider).request(GqlMutation.reorderFavorites, {
      idsVariableKey: ids,
      indexesVariableKey: indexes,
    }).getErrorOrNull();

    if (err != null) cancelEdit();
    return err;
  }

  Future<Object?> toggleFavorite(int id) async {
    final edit = state.value?.edit;
    if (edit == null) return null;

    final typeKey = switch (edit.editedType) {
      .anime => 'anime',
      .manga => 'manga',
      .characters => 'character',
      .staff => 'staff',
      .studios => 'studio',
    };

    return ref.read(repositoryProvider).request(GqlMutation.toggleFavorite, {
      typeKey: id,
    }).getErrorOrNull();
  }
}
