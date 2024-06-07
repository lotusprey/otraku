import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/studio/studio_filter_model.dart';

final studioFilterProvider = NotifierProvider.autoDispose
    .family<StudioFilterNotifier, StudioFilter, int>(
  StudioFilterNotifier.new,
);

class StudioFilterNotifier
    extends AutoDisposeFamilyNotifier<StudioFilter, int> {
  @override
  StudioFilter build(arg) => StudioFilter();

  @override
  set state(StudioFilter newState) => super.state = newState;
}
