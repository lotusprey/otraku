import 'package:flutter/material.dart';
import 'package:otraku/models/connection_model.dart';
import 'package:otraku/controllers/media_controller.dart';
import 'package:otraku/widgets/layouts/connections_grid.dart';
import 'package:otraku/widgets/navigation/bubble_tabs.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';

class MediaPeopleView {
  static List<Widget> children(BuildContext ctx, MediaController ctrl) => [
        SliverShadowAppBar([
          BubbleTabs(
            items: const {'Characters': false, 'Staff': true},
            current: () => ctrl.peopleTabToggled,
            onChanged: (bool val) {
              ctrl.scrollUpTo(0);
              ctrl.peopleTabToggled = val;
            },
            onSame: () => ctrl.scrollUpTo(0),
          ),
        ]),
        SliverPadding(
          padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
          sliver: !ctrl.peopleTabToggled
              ? _PeopleGrid(
                  items: ctrl.model!.charactersByLanguage(
                    ctrl.languages[ctrl.langIndex],
                  ),
                  placeholder: 'No Characters',
                  preferredSubtitle: ctrl.langIndex < ctrl.languages.length
                      ? ctrl.languages[ctrl.langIndex]
                      : null,
                )
              : _PeopleGrid(
                  items: ctrl.model!.staff.items,
                  placeholder: 'No Staff',
                ),
        ),
      ];
}

class _PeopleGrid extends StatelessWidget {
  _PeopleGrid({
    required this.items,
    required this.placeholder,
    this.preferredSubtitle,
  });

  final List<ConnectionModel> items;
  final String placeholder;
  final String? preferredSubtitle;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty)
      return SliverFillRemaining(
        child: Center(
          child: Text(
            placeholder,
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
      );

    return ConnectionsGrid(
      connections: items,
      preferredSubtitle: preferredSubtitle,
    );
  }
}
