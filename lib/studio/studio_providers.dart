import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/tile_item.dart';
import 'package:otraku/media/media_constants.dart';
import 'package:otraku/media/media_models.dart';
import 'package:otraku/studio/studio_models.dart';
import 'package:otraku/utils/api.dart';
import 'package:otraku/utils/graphql.dart';
import 'package:otraku/common/paged.dart';

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

final studioProvider =
    StateNotifierProvider.autoDispose.family<StudioNotifier, Studio, int>(
  (ref, int id) => StudioNotifier(id, ref.watch(studioFilterProvider(id))),
);

class StudioNotifier extends StateNotifier<Studio> {
  StudioNotifier(this.id, this.filter) : super(const Studio()) {
    fetch();
  }

  final int id;
  final StudioFilter filter;

  Future<void> fetch() async {
    var info = state.info;
    var media = state.media;
    var categories = {...state.categories};

    final data = await AsyncValue.guard(
      () => Api.get(GqlQuery.studio, {
        'id': id,
        'withInfo': info.valueOrNull == null,
        'sort': filter.sort.name,
        'onList': filter.onList,
        'page': media.valueOrNull?.next ?? 1,
        if (filter.isMain != null) 'isMain': filter.isMain,
      }),
    );

    if (info.valueOrNull == null) {
      info = await AsyncValue.guard(() {
        if (data.hasError) throw data.error!;
        return Future.value(StudioInfo(data.value!['Studio']));
      });
    }

    media = await AsyncValue.guard(() {
      if (data.hasError) throw data.error!;
      final map = data.value!['Studio']['media'];
      final value = media.valueOrNull ?? const Paged();

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

        var index = value.items.length;
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

      return Future.value(
        value.withNext(items, map['pageInfo']['hasNextPage'] ?? false),
      );
    });

    state = Studio(info: info, media: media, categories: categories);
  }
}
