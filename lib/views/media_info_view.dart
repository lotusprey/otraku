import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/controllers/explorer_controller.dart';
import 'package:otraku/enums/explorable.dart';
import 'package:otraku/enums/media_sort.dart';
import 'package:otraku/utils/filterable.dart';
import 'package:otraku/models/media_info_model.dart';
import 'package:otraku/views/home_view.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/fields/input_field_structure.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/toast.dart';

class MediaInfoView extends StatelessWidget {
  final MediaInfoModel info;

  MediaInfoView(this.info);

  @override
  Widget build(BuildContext context) {
    final tileCount = (MediaQuery.of(context).size.width - 10) ~/ 150;
    final tileAspectRatio =
        (((MediaQuery.of(context).size.width - 10) / tileCount) - 10) / 51.0;
    final infoTitles = [
      'Format',
      'Status',
      'Episodes',
      'Duration',
      'Chapters',
      'Volumes',
      'Start Date',
      'End Date',
      'Season',
      'Average Score',
      'Mean Score',
      'Popularity',
      'Favourites',
      'Source',
      'Origin'
    ];
    final infoChildren = [
      info.format,
      info.status,
      info.episodes,
      info.duration,
      info.chapters,
      info.volumes,
      info.startDate,
      info.endDate,
      info.season,
      info.averageScore,
      info.meanScore,
      info.popularity,
      info.favourites,
      info.source,
      info.countryOfOrigin,
    ];

    return SliverList(
      delegate: SliverChildListDelegate(
        [
          if (info.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: InputFieldStructure(
                title: 'Description',
                child: GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: Config.BORDER_RADIUS,
                    ),
                    child: Text(
                      info.description,
                      overflow: TextOverflow.fade,
                      maxLines: 5,
                    ),
                  ),
                  onTap: () => showPopUp(
                    context,
                    TextDialog(
                      title: 'Description',
                      text: info.description,
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            child: InputFieldStructure(
              title: 'Info',
              child: GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(0),
                semanticChildCount: infoTitles.length,
                crossAxisCount: tileCount,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: tileAspectRatio,
                children: [
                  for (int i = 0; i < infoChildren.length; i++)
                    if (infoChildren[i] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: Config.BORDER_RADIUS,
                          color: Theme.of(context).primaryColor,
                        ),
                        child: InputFieldStructure(
                          title: infoTitles[i],
                          child: Text(infoChildren[i].toString()),
                        ),
                      ),
                ],
              ),
            ),
          ),
          if (info.genres.isNotEmpty)
            _ScrollCards(
              title: 'Genres',
              items: info.genres,
              onTap: (index) {
                final explorable = Get.find<ExplorerController>();
                explorable.clearAllFilters(update: false);
                explorable.setFilterWithKey(
                  Filterable.SORT,
                  value: describeEnum(MediaSort.TRENDING_DESC),
                );
                explorable.setFilterWithKey(
                  Filterable.GENRE_IN,
                  value: [info.genres[index]],
                );
                explorable.type = info.browsable;
                explorable.search = '';
                Config.setHomeIndex(HomeView.EXPLORE);
                Get.until((route) => route.isFirst);
              },
              onLongTap: (index) => Toast.copy(context, info.genres[index]),
            ),
          if (info.studios.isNotEmpty)
            _ScrollCards(
              title: 'Studios',
              items: info.studios.keys.toList(),
              onTap: (index) => ExploreIndexer.openPage(
                id: info.studios[info.studios.keys.elementAt(index)]!,
                imageUrl: info.studios.keys.elementAt(index),
                browsable: Explorable.studio,
              ),
            ),
          if (info.producers.isNotEmpty)
            _ScrollCards(
              title: 'Producers',
              items: info.producers.keys.toList(),
              onTap: (index) => ExploreIndexer.openPage(
                id: info.producers[info.producers.keys.elementAt(index)]!,
                imageUrl: info.producers.keys.elementAt(index),
                browsable: Explorable.studio,
              ),
            ),
          const SizedBox(height: 10),
          if (info.romajiTitle != null) _Tiles('Romaji', [info.romajiTitle!]),
          if (info.englishTitle != null)
            _Tiles('English', [info.englishTitle!]),
          if (info.nativeTitle != null) _Tiles('Native', [info.nativeTitle!]),
          if (info.synonyms.isNotEmpty) _Tiles('Synonyms', info.synonyms),
        ],
      ),
    );
  }
}

class _ScrollCards extends StatelessWidget {
  final String title;
  final List<String> items;
  final Function(int) onTap;
  final Function(int)? onLongTap;

  _ScrollCards({
    required this.title,
    required this.items,
    required this.onTap,
    this.onLongTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
            child: Text(
              title,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 10),
              physics: Config.PHYSICS,
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, index) => GestureDetector(
                onTap: () => onTap(index),
                onLongPress: () => onLongTap?.call(index),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: Config.PADDING,
                  decoration: BoxDecoration(
                    borderRadius: Config.BORDER_RADIUS,
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Text(items[index]),
                ),
              ),
              itemCount: items.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tiles extends StatelessWidget {
  final String title;
  final List<String> items;

  _Tiles(this.title, this.items);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: InputFieldStructure(
        title: title,
        child: ListView.builder(
          padding: const EdgeInsets.all(0),
          shrinkWrap: true,
          physics: Config.PHYSICS,
          itemBuilder: (_, index) => GestureDetector(
            onTap: () => Toast.copy(context, items[index]),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: Config.BORDER_RADIUS,
                color: Theme.of(context).primaryColor,
              ),
              child: SingleChildScrollView(
                padding: Config.PADDING,
                scrollDirection: Axis.horizontal,
                physics: Config.PHYSICS,
                child: Text(items[index]),
              ),
            ),
          ),
          itemCount: items.length,
          itemExtent: Config.MATERIAL_TAP_TARGET_SIZE,
        ),
      ),
    );
  }
}
