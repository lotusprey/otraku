import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/media_controller.dart';
import 'package:otraku/models/entry_model.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/views/media_info_view.dart';
import 'package:otraku/views/media_relations_view.dart';
import 'package:otraku/views/media_social_view.dart';
import 'package:otraku/widgets/nav_scaffold.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/navigation/action_button.dart';
import 'package:otraku/widgets/navigation/media_header.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class MediaView extends StatelessWidget {
  final int id;
  final String? coverUrl;

  MediaView(this.id, this.coverUrl);

  @override
  Widget build(BuildContext context) {
    final coverWidth = MediaQuery.of(context).size.width < 430.0
        ? MediaQuery.of(context).size.width * 0.35
        : 150.0;
    final coverHeight = coverWidth / 0.7;
    final bannerHeight =
        coverHeight * 0.6 + Config.MATERIAL_TAP_TARGET_SIZE + 10;
    final headerHeight = bannerHeight + coverHeight * 0.6;
    final pageTop = headerHeight - Config.MATERIAL_TAP_TARGET_SIZE;

    final header = MediaHeader(
      ctrl: Get.find<MediaController>(tag: id.toString()),
      imageUrl: coverUrl,
      coverWidth: coverWidth,
      coverHeight: coverHeight,
      bannerHeight: bannerHeight,
      height: headerHeight,
    );

    return GetBuilder<MediaController>(
      tag: id.toString(),
      builder: (ctrl) {
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

        return NavScaffold(
          index: ctrl.tab,
          setPage: (page) => ctrl.tab = page,
          floating: _ActionButtons(ctrl, pageTop),
          items: const {
            'Info': Ionicons.book_outline,
            'Relations': Icons.emoji_people_outlined,
            'Social': Icons.rate_review_outlined,
          },
          child: ctrl.tab == MediaController.INFO
              ? MediaInfoView(ctrl, header)
              : ctrl.tab == MediaController.RELATIONS
                  ? MediaRelationsView(
                      ctrl,
                      header,
                      () => ctrl.scrollTo(pageTop),
                    )
                  : MediaSocialView(ctrl, header),
        );
      },
    );
  }
}

class _ActionButtons extends StatefulWidget {
  final MediaController ctrl;
  final double scrollTop;

  _ActionButtons(this.ctrl, this.scrollTop);

  @override
  __ActionButtonsState createState() => __ActionButtonsState();
}

class __ActionButtonsState extends State<_ActionButtons> {
  @override
  Widget build(BuildContext context) {
    final ctrl = widget.ctrl;
    final model = ctrl.model!;

    List<Widget> children = [
      if (ctrl.tab == MediaController.RELATIONS) ...[
        Obx(
          () {
            if (ctrl.relationsTab != MediaController.REL_CHARACTERS ||
                model.characters.items.isEmpty ||
                ctrl.availableLanguages.length < 2) return const SizedBox();

            return ActionButton(
              tooltip: 'Language',
              icon: Ionicons.globe_outline,
              onTap: () => Sheet.show(
                ctx: context,
                sheet: OptionSheet(
                  title: 'Language',
                  options: ctrl.availableLanguages,
                  index: ctrl.languageIndex,
                  onTap: (index) =>
                      ctrl.staffLanguage = ctrl.availableLanguages[index],
                ),
                isScrollControlled: true,
              ),
            );
          },
        ),
        const SizedBox(width: 10),
      ],
      ActionButton(
        icon: model.info.isFavourite ? Icons.favorite : Icons.favorite_border,
        tooltip: model.info.isFavourite ? 'Unfavourite' : 'Favourite',
        onTap: () => ctrl.toggleFavourite().then(
              (ok) => ok
                  ? setState(
                      () => model.info.isFavourite = !model.info.isFavourite,
                    )
                  : null,
            ),
      ),
      const SizedBox(width: 10),
      ActionButton(
        icon: model.entry.status == null ? Icons.add : Icons.edit,
        tooltip: model.entry.status == null ? 'Add' : 'Edit',
        onTap: () => ExploreIndexer.openEditPage(
          model.info.id,
          model.entry,
          (EntryModel entry) => setState(() => model.entry = entry),
        ),
      ),
    ];

    if (Config.storage.read(Config.LEFT_HANDED) ?? false)
      children = children.reversed.toList();

    return FloatingListener(
      scrollCtrl: ctrl.scrollCtrl,
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}
