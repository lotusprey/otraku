import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/extension/future_extension.dart';
import 'package:otraku/feature/studio/studio_filter_model.dart';
import 'package:otraku/util/paged.dart';
import 'package:otraku/feature/studio/studio_filter_provider.dart';
import 'package:otraku/feature/studio/studio_model.dart';
import 'package:otraku/feature/viewer/repository_provider.dart';
import 'package:otraku/util/graphql.dart';
import 'package:otraku/util/persistence.dart';

final studioProvider =
    AsyncNotifierProvider.autoDispose.family<StudioNotifier, Studio, int>(
  StudioNotifier.new,
);

final studioMediaProvider = AsyncNotifierProvider.autoDispose
    .family<StudioMediaNotifier, Paged<StudioMedia>, int>(
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

  Future<Object?> toggleFavorite() {
    return ref.read(repositoryProvider).request(
      GqlMutation.toggleFavorite,
      {'studio': arg},
    ).getErrorOrNull();
  }
}

class StudioMediaNotifier
    extends AutoDisposeFamilyAsyncNotifier<Paged<StudioMedia>, int> {
  late StudioFilter filter;

  @override
  FutureOr<Paged<StudioMedia>> build(arg) async {
    filter = ref.watch(studioFilterProvider(arg));
    return await _fetch(const Paged());
  }

  Future<void> fetch() async {
    final oldState = state.valueOrNull ?? const Paged();
    if (!oldState.hasNext) return;
    state = await AsyncValue.guard(() => _fetch(oldState));
  }

  Future<Paged<StudioMedia>> _fetch(Paged<StudioMedia> oldState) async {
    final data = await ref.read(repositoryProvider).request(GqlQuery.studio, {
      'id': arg,
      'withMedia': true,
      'page': oldState.next,
      'sort': filter.sort.value,
      'onList': filter.inLists,
      if (filter.isMain != null) 'isMain': filter.isMain,
    });

    final map = data['Studio']['media'];
    final items = <StudioMedia>[];
    for (final m in map['nodes']) {
      items.add(StudioMedia(m, Persistence().imageQuality));
    }

    return oldState.withNext(items, map['pageInfo']['hasNextPage'] ?? false);
  }
}
