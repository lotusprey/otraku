import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/edit/edit_model.dart';
import 'package:otraku/feature/media/media_provider.dart';
import 'package:otraku/feature/settings/settings_provider.dart';
import 'package:otraku/feature/viewer/api.dart';
import 'package:otraku/util/graphql.dart';

final oldEditProvider = FutureProvider.autoDispose.family(
  (ref, EditTag tag) async {
    if (ref.exists(mediaProvider(tag.id))) {
      final edit = ref.watch(mediaProvider(tag.id)).valueOrNull?.edit;
      if (edit != null) return edit;
    }

    final data = await Api.get(GqlQuery.entry, {'mediaId': tag.id});

    final settings = await ref.watch(
      settingsProvider.selectAsync((settings) => settings),
    );

    return Edit(data['Media'], settings);
  },
);

final newEditProvider =
    NotifierProvider.autoDispose.family<NewEditNotifier, Edit, EditTag>(
  NewEditNotifier.new,
);

class NewEditNotifier extends AutoDisposeFamilyNotifier<Edit, EditTag> {
  @override
  Edit build(arg) {
    final old = ref.watch(oldEditProvider(arg)).valueOrNull ?? Edit.temp();
    return old.copy(arg.setComplete);
  }

  @override
  Edit get state => super.state;

  Edit update(Edit Function(Edit) callback) => state = callback(state);
}
