import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/tile_item.dart';
import 'package:otraku/media/media_constants.dart';
import 'package:otraku/media/media_models.dart';
import 'package:otraku/studio/studio_models.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/common/pagination.dart';

/// Favorite/Unfavorite studio. Returns `true` if successful.
Future<bool> toggleFavoriteStudio(int studioId) async {
  try {
    await Api.get(GqlMutation.toggleFavorite, {'studio': studioId});
    return true;
  } catch (_) {
    return false;
  }
}

final studioFilterProvider =
    StateProvider.autoDispose.family((ref, _) => StudioFilter());

final studioProvider = StateNotifierProvider.autoDispose
    .family<StudioNotifier, AsyncValue<StudioState>, int>(
  (ref, int id) => StudioNotifier(id, ref.watch(studioFilterProvider(id))),
);

class StudioNotifier extends StateNotifier<AsyncValue<StudioState>> {
  StudioNotifier(this.id, this.filter)
      : super(const AsyncValue<StudioState>.loading()) {
    _fetch();
  }

  final int id;
  final StudioFilter filter;

  Future<void> _fetch() async {
    state = await AsyncValue.guard(() async {
      var data = await Api.get(GqlQuery.studio, {
        'id': id,
        'withInfo': true,
        'sort': filter.sort.name,
        'onList': filter.onList,
        if (filter.isMain != null) 'isMain': filter.isMain,
      });
      data = data['Studio'];

      return _initMedia(
        StudioState(Studio(data), Pagination(), {}),
        data['media'],
      );
    });
  }

  Future<void> fetchPage() async {
    final value = state.valueOrNull;
    if (value == null || !value.media.hasNext) return;

    state = await AsyncValue.guard(() async {
      var data = await Api.get(GqlQuery.studio, {
        'id': id,
        'sort': filter.sort.name,
        'onList': filter.onList,
        'page': value.media.next,
        if (filter.isMain != null) 'isMain': filter.isMain,
      });
      data = data['Studio'];

      return _initMedia(value, data['media']);
    });
  }

  StudioState _initMedia(StudioState s, Map<String, dynamic> data) {
    final items = <TileItem>[];

    if (filter.sort != MediaSort.START_DATE &&
        filter.sort != MediaSort.START_DATE_DESC) {
      for (final m in data['nodes']) {
        items.add(mediaItem(m));
      }
    } else {
      final key = filter.sort == MediaSort.START_DATE ||
              filter.sort == MediaSort.START_DATE_DESC
          ? 'startDate'
          : 'endDate';

      var index = s.media.items.length;

      for (final m in data['nodes']) {
        var category = m[key]?['year']?.toString();
        category ??=
            m['status'] == 'CANCELLED' ? 'Cancelled' : 'To Be Announced';

        if (!s.categories.containsKey(category)) {
          s.categories[category] = index;
        }

        items.add(mediaItem(m));

        index++;
      }
    }

    return StudioState(
      s.studio,
      s.media.append(items, data['pageInfo']['hasNextPage']),
      s.categories,
    );
  }
}
