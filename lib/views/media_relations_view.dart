import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/models/related_media_model.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/controllers/media_controller.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/layouts/connections_grid.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/navigation/bubble_tabs.dart';
import 'package:otraku/widgets/navigation/nav_bar.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class MediaRelationsView extends StatelessWidget {
  final MediaController ctrl;
  final Widget header;
  final void Function() scrollUp;
  MediaRelationsView(this.ctrl, this.header, this.scrollUp);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: Config.PHYSICS,
      controller: ctrl.scrollCtrl,
      slivers: [
        header,
        SliverShadowAppBar([
          BubbleTabs(
            options: ['Media', 'Characters', 'Staff'],
            values: [
              MediaController.REL_MEDIA,
              MediaController.REL_CHARACTERS,
              MediaController.REL_STAFF,
            ],
            current: () => ctrl.relationsTab,
            onNewValue: (dynamic val) {
              scrollUp();
              ctrl.relationsTab = val;
            },
            onSameValue: (dynamic _) => scrollUp(),
          ),
          const Spacer(),
          Obx(() {
            if (ctrl.relationsTab == MediaController.REL_CHARACTERS &&
                ctrl.model!.characters.items.isNotEmpty &&
                ctrl.availableLanguages.length > 1)
              return AppBarIcon(
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
            return const SizedBox();
          }),
        ]),
        SliverPadding(
          padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
          sliver: Obx(() {
            if (ctrl.relationsTab == MediaController.REL_MEDIA) {
              final other = ctrl.model!.otherMedia;

              if (other.isEmpty)
                return ctrl.isLoading
                    ? _Empty(null)
                    : _Empty('No Related Media');

              return _RelationsGrid(ctrl.model!.otherMedia);
            }

            if (ctrl.relationsTab == MediaController.REL_CHARACTERS) {
              if (ctrl.model!.characters.items.isEmpty)
                return ctrl.isLoading ? _Empty(null) : _Empty('No Characters');

              return ConnectionsGrid(
                connections: ctrl.model!.characters.items,
                preferredSubtitle: ctrl.staffLanguage,
              );
            }

            if (ctrl.model!.staff.items.isEmpty)
              return ctrl.isLoading ? _Empty(null) : _Empty('No Staff');

            return ConnectionsGrid(connections: ctrl.model!.staff.items);
          }),
        ),
        SliverToBoxAdapter(child: SizedBox(height: NavBar.offset(context))),
      ],
    );
  }
}

class _RelationsGrid extends StatelessWidget {
  final List<RelatedMediaModel> models;
  _RelationsGrid(this.models);

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: 300,
        height: 190,
      ),
      delegate: SliverChildBuilderDelegate(
        (_, index) => ExploreIndexer(
          id: models[index].id,
          imageUrl: models[index].imageUrl,
          explorable: models[index].explorable,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Hero(
                tag: models[index].id,
                child: ClipRRect(
                  borderRadius: Config.BORDER_RADIUS,
                  child: Container(
                    color: Theme.of(context).primaryColor,
                    child: FadeImage(models[index].imageUrl, width: 125),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          models[index].relationType!,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        Flexible(
                          child: Text(
                            models[index].text1,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (models[index].format != null)
                          Text(
                            models[index].format!,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        if (models[index].status != null)
                          Text(
                            models[index].status!,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        childCount: models.length,
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String? text;
  _Empty(this.text);

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: text == null
            ? Loader()
            : Text(text!, style: Theme.of(context).textTheme.subtitle1),
      ),
    );
  }
}
