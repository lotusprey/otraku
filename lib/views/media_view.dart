import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/media_controller.dart';
import 'package:otraku/models/edit_model.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/views/media_info_view.dart';
import 'package:otraku/views/media_other_view.dart';
import 'package:otraku/views/media_social_view.dart';
import 'package:otraku/widgets/layouts/nav_layout.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/navigation/action_button.dart';
import 'package:otraku/widgets/navigation/media_header.dart';
import 'package:otraku/widgets/overlays/gradient_sheets.dart';

class MediaView extends StatelessWidget {
  MediaView(this.id, this.coverUrl);

  final int id;
  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    final footer =
        SliverToBoxAdapter(child: SizedBox(height: NavLayout.offset(context)));

    const keys = [ValueKey(0), ValueKey(1), ValueKey(2)];

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
            index: ctrl.tab,
            onChanged: (page) => ctrl.tab = page,
            onSame: (_) => ctrl.scrollUpTo(0),
            trySubtab: (goRight) {
              if (ctrl.tab == MediaController.OTHER) {
                if (goRight && ctrl.otherTab < 2) {
                  ctrl.scrollUpTo(0);
                  ctrl.otherTab++;
                  return true;
                }
                if (!goRight && ctrl.otherTab > 0) {
                  ctrl.scrollUpTo(0);
                  ctrl.otherTab--;
                  return true;
                }
              }

              if (ctrl.tab == MediaController.SOCIAL) {
                if (goRight && ctrl.socialTab < 1) {
                  ctrl.scrollUpTo(0);
                  ctrl.socialTab++;
                  return true;
                }
                if (!goRight && ctrl.socialTab > 0) {
                  ctrl.scrollUpTo(0);
                  ctrl.socialTab--;
                  return true;
                }
              }

              return false;
            },
            floating: _ActionButtons(ctrl),
            items: const {
              'Info': Ionicons.book_outline,
              'Other': Icons.emoji_people_outlined,
              'Social': Icons.rate_review_outlined,
            },
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
      if (widget.ctrl.tab == MediaController.OTHER &&
          widget.ctrl.otherTab == MediaController.CHARACTERS &&
          model.characters.items.isNotEmpty &&
          widget.ctrl.availableLanguages.length > 1) ...[
        ActionButton(
          tooltip: 'Language',
          icon: Ionicons.globe_outline,
          onTap: () => showDragSheet(
            context,
            DynamicGradientDragSheet(
              onTap: (i) => widget.ctrl.language = i,
              itemCount: widget.ctrl.availableLanguages.length,
              itemBuilder: (_, i) => Text(
                widget.ctrl.availableLanguages[i],
                style: i != widget.ctrl.language
                    ? Theme.of(context).textTheme.headline1
                    : Theme.of(context).textTheme.headline1?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
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
        onTap: () => ExploreIndexer.openEditView(
          model.info.id,
          context,
          model.entry,
          (EditModel entry) => setState(() => model.entry = entry),
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
