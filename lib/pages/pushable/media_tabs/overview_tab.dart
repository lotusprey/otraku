import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/controllers/explorer.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/enums/media_sort_enum.dart';
import 'package:otraku/controllers/filterable.dart';
import 'package:otraku/models/page_data/media_overview.dart';
import 'package:otraku/pages/pushable/studio_page.dart';
import 'package:otraku/pages/tab_manager.dart';
import 'package:otraku/tools/fields/input_field_structure.dart';
import 'package:otraku/tools/overlays/dialogs.dart';
import 'package:otraku/tools/page_transition.dart';

class OverviewTab extends StatelessWidget {
  final _space = const SizedBox(height: 10);

  final MediaOverview overview;

  OverviewTab(this.overview);

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
      overview.format,
      overview.status,
      overview.episodes,
      overview.duration,
      overview.chapters,
      overview.volumes,
      overview.startDate,
      overview.endDate,
      overview.season,
      overview.averageScore,
      overview.meanScore,
      overview.popularity,
      overview.favourites,
      overview.source,
      overview.countryOfOrigin,
    ];

    return SliverPadding(
      padding: Config.PADDING,
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          [
            if (overview.description != null)
              InputFieldStructure(
                enforceHeight: false,
                title: 'Description',
                body: GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: Config.BORDER_RADIUS,
                    ),
                    child: Text(
                      overview.description,
                      style: Theme.of(context).textTheme.bodyText1,
                      overflow: TextOverflow.fade,
                      maxLines: 5,
                    ),
                  ),
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => PopUpAnimation(
                      TextDialog(
                        title: 'Description',
                        text: overview.description,
                      ),
                    ),
                  ),
                ),
              ),
            Text('Info', style: Theme.of(context).textTheme.subtitle1),
            const SizedBox(height: 5),
            GridView.count(
              shrinkWrap: true,
              padding: const EdgeInsets.all(0),
              physics: NeverScrollableScrollPhysics(),
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
                        enforceHeight: false,
                        enforcePadding: false,
                        title: infoTitles[i],
                        body: Text(
                          infoChildren[i].toString(),
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                    ),
              ],
            ),
            if (overview.genres != null && overview.genres.isNotEmpty) ...[
              _space,
              _ScrollTile(
                title: 'Genres',
                builder: (index) =>
                    _GenreLink(overview.genres[index], overview.browsable),
                itemCount: overview.genres.length,
              ),
            ],
            if (overview.studios != null &&
                overview.studios.item1.isNotEmpty) ...[
              _space,
              _ScrollTile(
                title: 'Studios',
                builder: (index) => _StudioLink(
                  overview.studios.item1[index],
                  overview.studios.item2[index],
                ),
                itemCount: overview.studios.item1.length,
              ),
            ],
            if (overview.producers != null &&
                overview.producers.item1.isNotEmpty) ...[
              _space,
              _ScrollTile(
                title: 'Producers',
                builder: (index) => _StudioLink(
                  overview.producers.item1[index],
                  overview.producers.item2[index],
                ),
                itemCount: overview.producers.item1.length,
              ),
            ],
            if (overview.romajiTitle != null) ...[
              _space,
              _ScrollTile(
                title: 'Romaji',
                builder: (_) => GestureDetector(
                  child: Text(
                    overview.romajiTitle,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  onLongPress: () => Clipboard.setData(
                    ClipboardData(text: overview.romajiTitle),
                  ),
                ),
                itemCount: 1,
              ),
            ],
            if (overview.englishTitle != null) ...[
              _space,
              _ScrollTile(
                title: 'English',
                builder: (_) => GestureDetector(
                  child: Text(
                    overview.englishTitle,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  onLongPress: () => Clipboard.setData(
                    ClipboardData(text: overview.englishTitle),
                  ),
                ),
                itemCount: 1,
              ),
            ],
            if (overview.nativeTitle != null) ...[
              _space,
              _ScrollTile(
                title: 'Native',
                builder: (_) => GestureDetector(
                  child: Text(
                    overview.nativeTitle,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  onLongPress: () => Clipboard.setData(
                    ClipboardData(text: overview.nativeTitle),
                  ),
                ),
                itemCount: 1,
              ),
            ],
            if (overview.synonyms != null && overview.synonyms.isNotEmpty) ...[
              _space,
              _ScrollTile(
                title: 'Synonyms',
                builder: (index) => GestureDetector(
                  child: Text(
                    overview.synonyms[index],
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  onLongPress: () => Clipboard.setData(
                    ClipboardData(text: overview.synonyms[index]),
                  ),
                ),
                itemCount: overview.synonyms.length,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScrollTile extends StatelessWidget {
  final String title;
  final Widget Function(int) builder;
  final int itemCount;

  _ScrollTile({
    @required this.title,
    @required this.builder,
    @required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: Config.BORDER_RADIUS,
        color: Theme.of(context).primaryColor,
      ),
      child: InputFieldStructure(
        enforceHeight: false,
        enforcePadding: false,
        title: title,
        body: Flexible(
          child: ListView.builder(
            physics: Config.PHYSICS,
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, index) {
              if (index % 2 == 0) {
                return builder(index ~/ 2);
              }
              return Text(', ', style: Theme.of(context).textTheme.bodyText1);
            },
            itemCount: itemCount * 2 - 1,
          ),
        ),
      ),
    );
  }
}

class _GenreLink extends StatelessWidget {
  final String name;
  final Browsable type;

  _GenreLink(this.name, this.type);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final explorable = Get.find<Explorer>();
        explorable.search = null;
        explorable.clearAllFilters(update: false);
        explorable.setFilterWithKey(
          Filterable.SORT,
          value: describeEnum(MediaSort.TRENDING_DESC),
        );
        explorable.setFilterWithKey(Filterable.GENRE_IN, value: [name]);
        explorable.type = type;
        Config.pageIndex = TabManager.EXPLORE;
        Get.until((route) => route.isFirst);
      },
      onLongPress: () => Clipboard.setData(ClipboardData(text: name)),
      child: Text(name, style: Theme.of(context).textTheme.bodyText2),
    );
  }
}

class _StudioLink extends StatelessWidget {
  final int id;
  final String name;

  _StudioLink(this.id, this.name);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(context, PageTransition.to(StudioPage(id, name))),
      onLongPress: () => Clipboard.setData(ClipboardData(text: name)),
      child: Text(name, style: Theme.of(context).textTheme.bodyText2),
    );
  }
}
