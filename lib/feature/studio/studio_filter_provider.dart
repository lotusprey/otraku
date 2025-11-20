import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/studio/studio_filter_model.dart';

final studioFilterProvider = NotifierProvider.autoDispose
    .family<StudioFilterNotifier, StudioFilter, int>(StudioFilterNotifier.new);

class StudioFilterNotifier extends Notifier<StudioFilter> {
  StudioFilterNotifier(this.arg);

  final int arg;

  @override
  StudioFilter build() => const StudioFilter();

  @override
  set state(StudioFilter newState) => super.state = newState;
}
