import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/discover/discover_models.dart';
import 'package:otraku/models/relation.dart';
import 'package:otraku/staff/staff_models.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/utils/pagination.dart';
import 'package:otraku/utils/settings.dart';

/// Favorite/Unfavorite staff. Returns `true` if successful.
Future<bool> toggleFavoriteStaff(int staffId) async {
  try {
    await Api.get(GqlMutation.toggleFavorite, {'staff': staffId});
    return true;
  } catch (_) {
    return false;
  }
}

final staffProvider = FutureProvider.autoDispose.family(
  (ref, int id) async {
    final data = await Api.get(
      GqlQuery.staff,
      {'id': id, 'withInfo': true},
    );
    return Staff(data['Staff']);
  },
);

final staffFilterProvider =
    StateProvider.autoDispose.family((ref, _) => StaffFilter());

final staffRelationProvider = ChangeNotifierProvider.autoDispose.family(
  (ref, int id) =>
      StaffRelationNotifier(id, ref.watch(staffFilterProvider(id))),
);

class StaffRelationNotifier extends ChangeNotifier {
  StaffRelationNotifier(this.id, this.filter) {
    _fetch();
  }

  final int id;
  final StaffFilter filter;
  final _characterMedia = <Relation>[];
  var _characters = const AsyncValue<Pagination<Relation>>.loading();
  var _roles = const AsyncValue<Pagination<Relation>>.loading();

  List<Relation> get characterMedia => _characterMedia;
  AsyncValue<Pagination<Relation>> get characters => _characters;
  AsyncValue<Pagination<Relation>> get roles => _roles;

  Future<void> _fetch() async {
    final data = await AsyncValue.guard<Map<String, dynamic>>(() async {
      final data = await Api.get(GqlQuery.staff, {
        'id': id,
        'withCharacters': true,
        'withRoles': true,
        'onList': filter.onList,
        'sort': filter.sort.name,
      });
      return data['Staff'];
    });

    if (data.hasError) {
      _characters = AsyncValue.error(data.error!, stackTrace: data.stackTrace);
      _roles = AsyncValue.error(data.error!, stackTrace: data.stackTrace);
      return;
    }

    _characters = AsyncValue.data(Pagination());
    _roles = AsyncValue.data(Pagination());

    _initCharacters(data.value!['characterMedia']);
    _initRoles(data.value!['staffMedia']);
    notifyListeners();
  }

  Future<void> fetchPage(bool ofCharacters) async {
    final value = ofCharacters ? _characters.valueOrNull : _roles.valueOrNull;
    if (value == null || !value.hasNext) return;

    final data = await AsyncValue.guard<Map<String, dynamic>>(() async {
      final data = await Api.get(GqlQuery.staff, {
        'id': id,
        'withCharacters': ofCharacters,
        'withRoles': !ofCharacters,
        'onList': filter.onList,
        'sort': filter.sort.name,
        'page': value.next,
      });
      return data['Staff'];
    });

    if (data.hasError) {
      ofCharacters
          ? _characters = AsyncValue.error(
              data.error!,
              stackTrace: data.stackTrace,
            )
          : _roles = AsyncValue.error(data.error!, stackTrace: data.stackTrace);
      return;
    }

    ofCharacters
        ? _initCharacters(data.value!['characterMedia'])
        : _initRoles(data.value!['staffMedia']);
    notifyListeners();
  }

  void _initCharacters(Map<String, dynamic> data) {
    var value = _characters.valueOrNull;
    if (value == null) return;

    final items = <Relation>[];
    for (final m in data['edges']) {
      final media = Relation(
        id: m['node']['id'],
        title: m['node']['title']['userPreferred'],
        imageUrl: m['node']['coverImage'][Settings().imageQuality],
        subtitle: Convert.clarifyEnum(m['node']['format']),
        type: m['node']['type'] == 'ANIME'
            ? DiscoverType.anime
            : DiscoverType.manga,
      );

      for (final c in m['characters']) {
        if (c == null) continue;

        _characterMedia.add(media);

        items.add(Relation(
          id: c['id'],
          title: c['name']['userPreferred'],
          imageUrl: c['image']['large'],
          type: DiscoverType.character,
          subtitle: Convert.clarifyEnum(m['characterRole']),
        ));
      }
    }

    value = value.append(items, data['pageInfo']['hasNextPage']);
    _characters = AsyncValue.data(value);
  }

  void _initRoles(Map<String, dynamic> data) {
    var value = _roles.valueOrNull;
    if (value == null) return;

    final items = <Relation>[];
    for (final s in data['edges'])
      items.add(Relation(
        id: s['node']['id'],
        title: s['node']['title']['userPreferred'],
        imageUrl: s['node']['coverImage'][Settings().imageQuality],
        subtitle: s['staffRole'],
        type: s['node']['type'] == 'ANIME'
            ? DiscoverType.anime
            : DiscoverType.manga,
      ));

    value = value.append(items, data['pageInfo']['hasNextPage']);
    _roles = AsyncValue.data(value);
  }
}
