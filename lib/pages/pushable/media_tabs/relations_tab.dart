import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/controllers/media.dart';
import 'package:otraku/models/transparent_image.dart';
import 'package:otraku/tools/browse_indexer.dart';

class RelationsTab extends StatelessWidget {
  final Media media;

  RelationsTab(this.media);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 20, bottom: 10, left: 10, right: 10),
      sliver: Obx(() {
        if (media.relationsTab == Media.REL_MEDIA &&
            media.mediaRelations.isNotEmpty)
          return SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 450,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.8,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, index) => BrowseIndexer(
                id: media.mediaRelations[index].id,
                tag: media.mediaRelations[index].imageUrl,
                browsable: media.mediaRelations[index].browsable,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: Config.BORDER_RADIUS,
                      child: Container(
                        color: Theme.of(context).primaryColor,
                        child: FadeInImage.memoryNetwork(
                          width: 100,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: transparentImage,
                          image: media.mediaRelations[index].imageUrl,
                          fadeInDuration: Config.FADE_DURATION,
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
                              if (media.mediaRelations[index].relationType !=
                                  null)
                                Text(
                                  media.mediaRelations[index].relationType,
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                              Flexible(
                                child: Text(
                                  media.mediaRelations[index].title,
                                  style: Theme.of(context).textTheme.bodyText1,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (media.mediaRelations[index].format != null)
                                Text(
                                  media.mediaRelations[index].format,
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                              if (media.mediaRelations[index].status != null)
                                Text(
                                  media.mediaRelations[index].status,
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
              childCount: media.mediaRelations.length,
            ),
          );

        if (media.relationsTab == Media.REL_CHARACTERS) {}
        if (media.relationsTab == Media.REL_STAFF) {}

        return const SizedBox();
      }),
    );
  }
}
