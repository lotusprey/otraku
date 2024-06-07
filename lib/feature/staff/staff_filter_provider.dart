import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/staff/staff_filter_model.dart';

final staffFilterProvider =
    NotifierProvider.autoDispose.family<StaffFilterNotifier, StaffFilter, int>(
  StaffFilterNotifier.new,
);

class StaffFilterNotifier extends AutoDisposeFamilyNotifier<StaffFilter, int> {
  @override
  StaffFilter build(arg) => StaffFilter();

  @override
  set state(StaffFilter newState) => super.state = newState;
}
