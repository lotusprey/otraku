import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/studio/studio_filter_model.dart';
import 'package:otraku/model/tile_item.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/feature/studio/studio_filter_provider.dart';
import 'package:otraku/feature/studio/studio_model.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';
import 'package:otraku/util/graphql.dart';

final studioProvider =
    AsyncNotifierProvider.autoDispose.family<StudioNotifier, Studio, int>(
  StudioNotifier.new,
);

final studioMediaProvider = AsyncNotifierProvider.autoDispose
    .family<StudioMediaNotifier, StudioMedia, int>(
  StudioMediaNotifier.new,
);

class StudioNotifier extends AutoDisposeFamilyAsyncNotifier<Studio, int> {
  @override
  FutureOr<Studio> build(arg) async {
    final data = await ref
        .read(repositoryProvider)
        .request(GqlQuery.studio, {'id': arg, 'withInfo': true});
    return Studio(data['Studio']);
  }

  Future<bool> toggleFavorite() {
    return ref.read(repositoryProvider).request(
      GqlMutation.toggleFavorite,
      {'studio': arg},
    ).then((_) => true, onError: (_) => false);
  }
}

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

    final data = await ref.read(repositoryProvider).request(GqlQuery.studio, {
      'id': arg,
      'withMedia': true,
      'page': oldState.media.next,
      'sort': filter.sort.value,
      'onList': filter.inLists,
      if (filter.isMain != null) 'isMain': filter.isMain,
    });

    final map = data['Studio']['media'];
    final items = <TileItem>[];
    if (filter.sort != MediaSort.startDate &&
        filter.sort != MediaSort.startDateDesc) {
      for (final m in map['nodes']) {
        items.add(mediaItem(m));
      }
    } else {
      final key = filter.sort == MediaSort.startDate ||
              filter.sort == MediaSort.startDateDesc
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
