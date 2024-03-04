import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/models/tile_item.dart';
import 'package:otraku/modules/media/media_constants.dart';
import 'package:otraku/modules/media/media_models.dart';
import 'package:otraku/modules/studio/studio_models.dart';
import 'package:otraku/common/utils/api.dart';
import 'package:otraku/common/utils/graphql.dart';

/// Favorite/Unfavorite studio. Returns `true` if successful.
Future<bool> toggleFavoriteStudio(int studioId) async {
  try {
    await Api.get(GqlMutation.toggleFavorite, {'studio': studioId});
    return true;
  } catch (_) {
    return false;
  }
}

final studioProvider = FutureProvider.autoDispose.family<Studio, int>(
  (ref, id) async {
    final data = await Api.get(GqlQuery.studio, {'id': id, 'withInfo': true});
    return Studio(data['Studio']);
  },
);

final studioMediaProvider = AsyncNotifierProvider.autoDispose
    .family<StudioMediaNotifier, StudioMedia, int>(
  StudioMediaNotifier.new,
);

final studioFilterProvider = NotifierProvider.autoDispose
    .family<StudioFilterNotifier, StudioFilter, int>(StudioFilterNotifier.new);

class StudioMediaNotifier
    extends AutoDisposeFamilyAsyncNotifier<StudioMedia, int> {
  late StudioFilter filter;

  @override
  FutureOr<StudioMedia> build(arg) async {
    filter = ref.watch(studioFilterProvider(arg));
    return await _fetch(const StudioMedia());
  }

  Future<void> fetch() async {
    final oldState = state.valueOrNull ?? const StudioMedia();
    if (!oldState.media.hasNext) return;
    state = await AsyncValue.guard(() => _fetch(oldState));
  }

  Future<StudioMedia> _fetch(StudioMedia oldState) async {
    final categories = {...oldState.categories};

    final data = await Api.get(GqlQuery.studio, {
      'id': arg,
      'withMedia': true,
      'page': oldState.media.next,
      'sort': filter.sort.name,
      'onList': filter.inLists,
      if (filter.isMain != null) 'isMain': filter.isMain,
    });

    final map = data['Studio']['media'];
    final items = <TileItem>[];
    if (filter.sort != MediaSort.START_DATE &&
        filter.sort != MediaSort.START_DATE_DESC) {
      for (final m in map['nodes']) {
        items.add(mediaItem(m));
      }
    } else {
      final key = filter.sort == MediaSort.START_DATE ||
              filter.sort == MediaSort.START_DATE_DESC
          ? 'startDate'
          : 'endDate';

      var index = oldState.media.items.length;
      for (final m in map['nodes']) {
        var category = m[key]?['year']?.toString();
        category ??=
            m['status'] == 'CANCELLED' ? 'Cancelled' : 'To Be Announced';

        if (!categories.containsKey(category)) {
          categories[category] = index;
        }

        items.add(mediaItem(m));

        index++;
      }
    }

    return StudioMedia(
      media: oldState.media.withNext(
        items,
        map['pageInfo']['hasNextPage'] ?? false,
      ),
      categories: categories,
    );
  }
}

class StudioFilterNotifier
    extends AutoDisposeFamilyNotifier<StudioFilter, int> {
  @override
  StudioFilter build(arg) => StudioFilter();

  @override
  set state(StudioFilter newState) => super.state = newState;
}
