import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/media_controller.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/utils/scrolling_controller.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/views/edit_view.dart';
import 'package:otraku/views/media_info_view.dart';
import 'package:otraku/views/media_other_view.dart';
import 'package:otraku/views/media_people_view.dart';
import 'package:otraku/views/media_social_view.dart';
import 'package:otraku/widgets/layouts/nav_layout.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/navigation/action_button.dart';
import 'package:otraku/widgets/navigation/media_header.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class MediaView extends StatelessWidget {
  MediaView(this.id, this.coverUrl);

  final int id;
  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    final footer =
        SliverToBoxAdapter(child: SizedBox(height: NavLayout.offset(context)));

    const keys = [ValueKey(0), ValueKey(1), ValueKey(2), ValueKey(3)];

    return GetBuilder<MediaController>(
      init: MediaController(id),
      id: MediaController.ID_BASE,
      tag: id.toString(),
      builder: (ctrl) {
        final header = MediaHeader(ctrl: ctrl, imageUrl: coverUrl);

        if (ctrl.model == null)
          return Scaffold(
            body: SafeArea(
              child: CustomScrollView(
                slivers: [
                  header,
                  const SliverFillRemaining(child: Center(child: Loader())),
                ],
              ),
            ),
          );

        return GetBuilder<MediaController>(
          id: MediaController.ID_OUTER,
          tag: id.toString(),
          builder: (_) => NavLayout(
            navRow: NavIconRow(
              index: ctrl.tab,
              onChanged: (page) => ctrl.tab = page,
              onSame: (_) => ctrl.scrollCtrl.scrollUpTo(0),
              items: const {
                'Info': Ionicons.book_outline,
                'Other': Ionicons.layers_outline,
                'People': Icons.emoji_people_outlined,
                'Social': Ionicons.stats_chart_outline,
              },
            ),
            trySubtab: (goRight) {
              if (ctrl.tab == MediaController.OTHER) {
                if (goRight && !ctrl.otherTabToggled) {
                  ctrl.scrollCtrl.scrollUpTo(0);
                  ctrl.otherTabToggled = true;
                  return true;
                }
                if (!goRight && ctrl.otherTabToggled) {
                  ctrl.scrollCtrl.scrollUpTo(0);
                  ctrl.otherTabToggled = false;
                  return true;
                }
              }

              if (ctrl.tab == MediaController.PEOPLE) {
                if (goRight && !ctrl.peopleTabToggled) {
                  ctrl.scrollCtrl.scrollUpTo(0);
                  ctrl.peopleTabToggled = true;
                  return true;
                }
                if (!goRight && ctrl.peopleTabToggled) {
                  ctrl.scrollCtrl.scrollUpTo(0);
                  ctrl.peopleTabToggled = false;
                  return true;
                }
              }

              if (ctrl.tab == MediaController.SOCIAL) {
                if (goRight && !ctrl.socialTabToggled) {
                  ctrl.scrollCtrl.scrollUpTo(0);
                  ctrl.socialTabToggled = true;
                  return true;
                }
                if (!goRight && ctrl.socialTabToggled) {
                  ctrl.scrollCtrl.scrollUpTo(0);
                  ctrl.socialTabToggled = false;
                  return true;
                }
              }

              return false;
            },
            floating: _ActionButtons(ctrl),
            child: GetBuilder<MediaController>(
              key: keys[ctrl.tab],
              id: MediaController.ID_INNER,
              tag: id.toString(),
              builder: (_) => CustomScrollView(
                controller: ctrl.scrollCtrl,
                physics: Consts.PHYSICS,
                slivers: [
                  header,
                  if (ctrl.tab == MediaController.INFO)
                    ...MediaInfoView.children(context, ctrl)
                  else if (ctrl.tab == MediaController.OTHER)
                    ...MediaOtherView.children(context, ctrl)
                  else if (ctrl.tab == MediaController.PEOPLE)
                    ...MediaPeopleView.children(context, ctrl)
                  else
                    ...MediaSocialView.children(context, ctrl),
                  footer,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActionButtons extends StatefulWidget {
  _ActionButtons(this.ctrl);

  final MediaController ctrl;

  @override
  __ActionButtonsState createState() => __ActionButtonsState();
}

class __ActionButtonsState extends State<_ActionButtons> {
  @override
  Widget build(BuildContext context) {
    final model = widget.ctrl.model!;

    List<Widget> children = [
      if (widget.ctrl.tab == MediaController.PEOPLE &&
          !widget.ctrl.peopleTabToggled &&
          widget.ctrl.languages.length > 1) ...[
        ActionButton(
          tooltip: 'Language',
          icon: Ionicons.globe_outline,
          onTap: () => showSheet(
            context,
            DynamicGradientDragSheet(
              onTap: (i) {
                widget.ctrl.scrollCtrl.scrollUpTo(0);
                widget.ctrl.langIndex = i;
              },
              itemCount: widget.ctrl.languages.length,
              itemBuilder: (_, i) => Text(
                widget.ctrl.languages[i],
                style: i != widget.ctrl.langIndex
                    ? Theme.of(context).textTheme.headline1
                    : Theme.of(context).textTheme.headline1?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
      ActionButton(
        icon: model.info.isFavourite ? Icons.favorite : Icons.favorite_border,
        tooltip: model.info.isFavourite ? 'Unfavourite' : 'Favourite',
        onTap: () => widget.ctrl.toggleFavourite().then((_) => setState(() {})),
      ),
      const SizedBox(width: 10),
      ActionButton(
        icon: model.entry.status == null ? Icons.add : Icons.edit,
        tooltip: model.entry.status == null ? 'Add' : 'Edit',
        onTap: () => showSheet(
          context,
          EditView(
            model.info.id,
            model: model.entry,
            callback: (entry) => setState(() => model.entry = entry),
          ),
        ),
      ),
    ];

    if (Settings().leftHanded) children = children.reversed.toList();

    return FloatingListener(
      scrollCtrl: widget.ctrl.scrollCtrl,
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}
