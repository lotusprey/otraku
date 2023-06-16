import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/modules/home/home_provider.dart';
import 'package:otraku/modules/schedule/schedule_models.dart';
import 'package:otraku/common/utils/api.dart';
import 'package:otraku/common/utils/graphql.dart';
import 'package:otraku/common/models/paged.dart';

final scheduleAnimeProvider = StateNotifierProvider.autoDispose<
    ScheduleMediaNotifier, AsyncValue<Paged<List<ScheduleAiringScheduleItem>>>>(
  (ref) {
    return ScheduleMediaNotifier(
      ref.watch(homeProvider.select((s) => s.didLoadDiscover)),
    );
  },
);

class ScheduleMediaNotifier
    extends StateNotifier<AsyncValue<Paged<List<ScheduleAiringScheduleItem>>>> {
  ScheduleMediaNotifier(bool shouldLoad) : super(const AsyncValue.loading()) {
    if (shouldLoad) fetch();
  }

  List<List<ScheduleAiringScheduleItem>> sortItems(items) {
    final List<List<ScheduleAiringScheduleItem>> sortedItems = [];

    for (var item in items) {
      final DateTime currentTime = DateTime.now();
      final DateTime airingTime =
          DateTime.fromMillisecondsSinceEpoch(item.airingAt * 1000);
      final Duration difference = airingTime.difference(currentTime);

      final List<ScheduleAiringScheduleItem>? scheduleItems =
          sortedItems.elementAtOrNull(difference.inDays);

      if (scheduleItems == null) {
        sortedItems.insert(difference.inDays, [item]);
      } else {
        scheduleItems.add(item);
      }
    }

    return sortedItems;
  }

  Future<void> fetch() async {
    state = await AsyncValue.guard(() async {
      final value = state.valueOrNull ?? const Paged();

      final currentTime = DateTime.now();
      final data = await Api.get(GqlQuery.schedule, {
        'page': value.next,
        'weekStart': (currentTime.millisecondsSinceEpoch / 1000).floor(),
        'weekEnd': (DateTime(currentTime.year, currentTime.month,
                        currentTime.day + 6, 23, 59)
                    .millisecondsSinceEpoch /
                1000)
            .floor()
      });

      final items = <ScheduleAiringScheduleItem>[];
      for (final m in data['Page']['airingSchedules']) {
        items.add(ScheduleAiringScheduleItem(m));
      }

      return value.withNext(
        sortItems(items),
        data['Page']['pageInfo']['hasNextPage'] ?? false,
      );
    });
  }
}
