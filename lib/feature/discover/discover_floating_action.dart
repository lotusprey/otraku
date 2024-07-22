import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/scaffold_extension.dart';
import 'package:otraku/feature/discover/discover_filter_provider.dart';
import 'package:otraku/feature/discover/discover_models.dart';
import 'package:otraku/widget/overlays/sheets.dart';

class DiscoverFloatingAction extends StatelessWidget {
  const DiscoverFloatingAction() : super(key: const Key('switchDiscover'));

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final type = ref.watch(discoverFilterProvider.select((s) => s.type));

        return FloatingActionButton(
          tooltip: 'Types',
          onPressed: () {
            showSheet(
              context,
              SimpleSheet.list(
                [
                  for (final discoverType in DiscoverType.values)
                    ListTile(
                      title: Text(discoverType.label),
                      leading: Icon(_typeIcon(discoverType)),
                      selected: discoverType == type,
                      onTap: () {
                        ref
                            .read(discoverFilterProvider.notifier)
                            .update((s) => s.copyWith(type: discoverType));
                        Navigator.pop(context);
                      },
                    ),
                ],
              ),
            );
          },
          child: DraggableIcon(
            icon: _typeIcon(type),
            onSwipe: (goRight) {
              var type = ref.read(discoverFilterProvider).type;

              if (goRight) {
                if (type.index < DiscoverType.values.length - 1) {
                  type = DiscoverType.values.elementAt(type.index + 1);
                } else {
                  type = DiscoverType.values.first;
                }
              } else {
                if (type.index > 0) {
                  type = DiscoverType.values.elementAt(type.index - 1);
                } else {
                  type = DiscoverType.values.last;
                }
              }

              ref
                  .read(discoverFilterProvider.notifier)
                  .update((s) => s.copyWith(type: type));
              return _typeIcon(type);
            },
          ),
        );
      },
    );
  }

  static IconData _typeIcon(DiscoverType type) => switch (type) {
        DiscoverType.anime => Ionicons.film_outline,
        DiscoverType.manga => Ionicons.book_outline,
        DiscoverType.character => Ionicons.man_outline,
        DiscoverType.staff => Ionicons.mic_outline,
        DiscoverType.studio => Ionicons.business_outline,
        DiscoverType.user => Ionicons.person_outline,
        DiscoverType.review => Icons.rate_review_outlined,
      };
}
