import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/controllers/media.dart';
import 'package:otraku/helpers/model_helper.dart';
import 'package:otraku/tools/browse_indexer.dart';
import 'package:otraku/tools/layouts/connections_grid.dart';
import 'package:otraku/tools/loader.dart';
import 'package:otraku/tools/navigation/bubble_tabs.dart';
import 'package:otraku/tools/overlays/option_sheet.dart';

class RelationList extends StatelessWidget {
  final Media media;

  RelationList(this.media);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 5, bottom: 10, left: 10, right: 10),
      sliver: Obx(() {
        if (media.relationsTab == Media.REL_MEDIA)
          return media.otherMedia.isNotEmpty
              ? SliverGrid(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 450,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.7,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, index) => BrowseIndexer(
                      id: media.otherMedia[index].id,
                      imageUrl: media.otherMedia[index].imageUrl,
                      browsable: media.otherMedia[index].browsable,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            flex: 1,
                            child: ClipRRect(
                              borderRadius: Config.BORDER_RADIUS,
                              child: Container(
                                color: Theme.of(context).primaryColor,
                                child: FadeInImage.memoryNetwork(
                                  height: double.infinity,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: ModelHelper.transparentImage,
                                  image: media.otherMedia[index].imageUrl,
                                  fadeInDuration: Config.FADE_DURATION,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            flex: 3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (media.otherMedia[index].relationType !=
                                        null)
                                      Text(
                                        media.otherMedia[index].relationType,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2,
                                      ),
                                    Flexible(
                                      child: Text(
                                        media.otherMedia[index].title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                        overflow: TextOverflow.fade,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (media.otherMedia[index].format != null)
                                      Text(
                                        media.otherMedia[index].format,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1,
                                      ),
                                    if (media.otherMedia[index].status != null)
                                      Text(
                                        media.otherMedia[index].status,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    childCount: media.otherMedia.length,
                  ),
                )
              : _Empty('No related media');

        if (media.relationsTab == Media.REL_CHARACTERS &&
            media.characters != null) {
          return media.characters.items.isNotEmpty
              ? ConnectionsGrid(
                  connections: media.characters.items,
                  loadMore: () {
                    if (media.characters.hasNextPage)
                      media.fetchRelationPage(true);
                  },
                  preferredSubtitle: media.staffLanguage,
                )
              : _Empty('No Characters');
        }

        if (media.relationsTab == Media.REL_STAFF && media.staff != null) {
          return media.staff.items.isNotEmpty
              ? ConnectionsGrid(
                  connections: media.staff.items,
                  loadMore: () {
                    if (media.staff.hasNextPage) media.fetchRelationPage(false);
                  },
                )
              : _Empty('No Staff');
        }

        return const SliverFillRemaining(child: Center(child: Loader()));
      }),
    );
  }
}

class _Empty extends StatelessWidget {
  final String text;

  _Empty(this.text);

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
        child: Center(
      child: Text(
        text,
        style: Theme.of(context).textTheme.subtitle1,
      ),
    ));
  }
}

class RelationControls extends StatelessWidget {
  final Media media;

  RelationControls(this.media);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: SizedBox(
          height: Config.MATERIAL_TAP_TARGET_SIZE,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BubbleTabs(
                options: ['Media', 'Characters', 'Staff'],
                values: [
                  Media.REL_MEDIA,
                  Media.REL_CHARACTERS,
                  Media.REL_STAFF,
                ],
                initial: media.relationsTab,
                onNewValue: (val) => media.relationsTab = val,
                onSameValue: (_) {},
              ),
              Obx(() {
                if (media.relationsTab == Media.REL_CHARACTERS &&
                    media.characters != null &&
                    media.characters.items.isNotEmpty &&
                    media.availableLanguages.length > 1)
                  return IconButton(
                    icon: const Icon(Icons.language),
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      builder: (_) => OptionSheet(
                        title: 'Language',
                        options: media.availableLanguages,
                        index: media.languageIndex,
                        onTap: (index) => media.staffLanguage =
                            media.availableLanguages[index],
                      ),
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                    ),
                  );
                return const SizedBox();
              }),
            ],
          ),
        ),
      ),
    );
  }
}
