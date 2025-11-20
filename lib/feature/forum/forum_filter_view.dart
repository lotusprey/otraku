import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/forum/forum_filter_model.dart';
import 'package:otraku/feature/forum/forum_filter_provider.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/input/chip_selector.dart';
import 'package:otraku/widget/input/stateful_tiles.dart';
import 'package:otraku/widget/sheets.dart';

void showForumFilterSheet(BuildContext context, WidgetRef ref) async {
  var filter = ref.read(forumFilterProvider);

  await showSheet(
    context,
    SimpleSheet(
      initialHeight: Theming.normalTapTarget * 4,
      builder: (context, scrollCtrl) => ListView(
        controller: scrollCtrl,
        padding: const .only(top: Theming.offset),
        children: [
          Padding(
            padding: const .symmetric(horizontal: Theming.offset),
            child: ChipSelector.ensureSelected(
              title: 'Sort',
              items: ThreadSort.values.map((v) => (v.label, v)).toList(),
              value: filter.sort,
              onChanged: (v) => filter = filter.copyWith(sort: v),
            ),
          ),
          Padding(
            padding: const .symmetric(horizontal: Theming.offset),
            child: ChipSelector(
              title: 'Category',
              items: ThreadCategory.values.map((v) => (v.label, v)).toList(),
              value: filter.category,
              onChanged: (v) => filter = filter.copyWith(category: (v,)),
            ),
          ),
          StatefulSwitchListTile(
            title: const Text('Subscribed'),
            value: filter.isSubscribed,
            onChanged: (v) => filter = filter.copyWith(isSubscribed: v),
          ),
        ],
      ),
    ),
  );

  ref.read(forumFilterProvider.notifier).update((_) => filter);
}
