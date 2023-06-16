import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/modules/home/home_provider.dart';
import 'package:otraku/modules/schedule/schedule_models.dart';
import 'package:otraku/common/utils/api.dart';
import 'package:otraku/common/utils/graphql.dart';
import 'package:otraku/common/models/paged.dart';

void scheduleLoadMore(WidgetRef ref) =>
    ref.read(scheduleAnimeProvider.notifier).fetch();

final scheduleAnimeProvider = StateNotifierProvider.autoDispose<
    ScheduleMediaNotifier, AsyncValue<Paged<ScheduleAiringScheduleItem>>>(
  (ref) {
    return ScheduleMediaNotifier(
      ref.watch(homeProvider.select((s) => s.didLoadDiscover)),
    );
  },
);

class ScheduleMediaNotifier
    extends StateNotifier<AsyncValue<Paged<ScheduleAiringScheduleItem>>> {
  ScheduleMediaNotifier(bool shouldLoad) : super(const AsyncValue.loading()) {
    if (shouldLoad) fetch();
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
        items,
        data['Page']['pageInfo']['hasNextPage'] ?? false,
      );
    });
  }
}
