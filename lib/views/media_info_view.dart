import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/home_controller.dart';
import 'package:otraku/controllers/media_controller.dart';
import 'package:otraku/constants/config.dart';
import 'package:otraku/controllers/explore_controller.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/constants/media_sort.dart';
import 'package:otraku/utils/filterable.dart';
import 'package:otraku/views/home_view.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/fields/input_field_structure.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/toast.dart';

class MediaInfoView {
  static List<Widget> children(BuildContext ctx, MediaController ctrl) {
    final model = ctrl.model!.info;

    final tileCount = (MediaQuery.of(ctx).size.width - 10) ~/ 150;
    final tileAspectRatio =
        (((MediaQuery.of(ctx).size.width - 10) / tileCount) - 10) / 51.0;
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
      model.format,
      model.status,
      model.episodes,
      model.duration,
      model.chapters,
      model.volumes,
      model.startDate,
      model.endDate,
      model.season,
      model.averageScore,
      model.meanScore,
      model.popularity,
      model.favourites,
      model.source,
      model.countryOfOrigin,
    ];
    for (int i = infoChildren.length - 1; i >= 0; i--)
      if (infoChildren[i] == null) {
        infoChildren.removeAt(i);
        infoTitles.removeAt(i);
      }

    return [
      if (model.description.isNotEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: Config.PADDING,
            child: InputFieldStructure(
              title: 'Description',
              child: GestureDetector(
                child: Container(
                  padding: Config.PADDING,
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.surface,
                    borderRadius: Config.BORDER_RADIUS,
                  ),
                  child: Text(
                    model.description,
                    overflow: TextOverflow.fade,
                    maxLines: 5,
                  ),
                ),
                onTap: () => showPopUp(
                  ctx,
                  TextDialog(title: 'Description', text: model.description),
                ),
              ),
            ),
          ),
        ),
      const _Section('Info'),
      SliverPadding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 5),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            crossAxisCount: tileCount,
            childAspectRatio: tileAspectRatio,
          ),
          delegate: SliverChildBuilderDelegate(
            (_, i) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: Config.BORDER_RADIUS,
                color: Theme.of(ctx).colorScheme.surface,
              ),
              child: InputFieldStructure(
                title: infoTitles[i],
                child: Text(infoChildren[i].toString()),
              ),
            ),
            childCount: infoChildren.length,
          ),
        ),
      ),
      if (model.genres.isNotEmpty)
        _ScrollCards(
          title: 'Genres',
          items: model.genres,
          onTap: (index) {
            final explorable = Get.find<ExploreController>();
            explorable.clearAllFilters(update: false);
            explorable.setFilterWithKey(
              Filterable.SORT,
              value: describeEnum(MediaSort.TRENDING_DESC),
            );
            explorable.setFilterWithKey(
              Filterable.GENRE_IN,
              value: [model.genres[index]],
            );
            explorable.type = model.type;
            explorable.search = '';
            Get.find<HomeController>().homeTab = HomeView.EXPLORE;
            Navigator.popUntil(ctx, (r) => r.isFirst);
          },
        ),
      if (model.studios.isNotEmpty)
        _ScrollCards(
          title: 'Studios',
          items: model.studios.keys.toList(),
          onTap: (index) => ExploreIndexer.openView(
            ctx: ctx,
            id: model.studios[model.studios.keys.elementAt(index)]!,
            imageUrl: model.studios.keys.elementAt(index),
            explorable: Explorable.studio,
          ),
        ),
      if (model.producers.isNotEmpty)
        _ScrollCards(
          title: 'Producers',
          items: model.producers.keys.toList(),
          onTap: (index) => ExploreIndexer.openView(
            ctx: ctx,
            id: model.producers[model.producers.keys.elementAt(index)]!,
            imageUrl: model.producers.keys.elementAt(index),
            explorable: Explorable.studio,
          ),
        ),
      if (model.romajiTitle != null) ...[
        const _Section('Romaji'),
        _Titles([model.romajiTitle!]),
      ],
      if (model.englishTitle != null) ...[
        const _Section('English'),
        _Titles([model.englishTitle!]),
      ],
      if (model.nativeTitle != null) ...[
        const _Section('Native'),
        _Titles([model.nativeTitle!]),
      ],
      if (model.synonyms.isNotEmpty) ...[
        const _Section('Synonyms'),
        _Titles(model.synonyms),
      ],
      if (model.tags.isNotEmpty) ...[
        const _Section('Tags'),
        _Tags(ctrl),
      ],
    ];
  }
}

class _Section extends StatelessWidget {
  final String title;
  const _Section(this.title);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(title, style: Theme.of(context).textTheme.subtitle1),
      ),
    );
  }
}

class _ScrollCards extends StatelessWidget {
  final String title;
  final List<String> items;
  final void Function(int) onTap;

  _ScrollCards({
    required this.title,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 10),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
              child: Text(title, style: Theme.of(context).textTheme.subtitle1),
            ),
            SizedBox(
              height: 40,
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 10),
                physics: Config.PHYSICS,
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, index) => GestureDetector(
                  onTap: () => onTap(index),
                  onLongPress: () => Toast.copy(context, items[index]),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: Config.PADDING,
                    decoration: BoxDecoration(
                      borderRadius: Config.BORDER_RADIUS,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: Text(items[index]),
                  ),
                ),
                itemCount: items.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Titles extends StatelessWidget {
  final List<String> titles;
  _Titles(this.titles);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, i) => SizedBox(
            height: Config.MATERIAL_TAP_TARGET_SIZE + 10,
            child: GestureDetector(
              onTap: () => Toast.copy(context, titles[i]),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: Config.BORDER_RADIUS,
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: SingleChildScrollView(
                  padding: Config.PADDING,
                  scrollDirection: Axis.horizontal,
                  physics: Config.PHYSICS,
                  child: Center(child: Text(titles[i])),
                ),
              ),
            ),
          ),
          childCount: titles.length,
        ),
      ),
    );
  }
}

class _Tags extends StatefulWidget {
  final MediaController ctrl;
  _Tags(this.ctrl);
  @override
  __TagsState createState() => __TagsState();
}

class __TagsState extends State<_Tags> {
  bool _hasSpoilers = false;

  @override
  void initState() {
    super.initState();
    for (final t in widget.ctrl.model!.info.tags)
      if (t.isSpoiler) {
        _hasSpoilers = true;
        break;
      }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.ctrl;

    late SliverChildBuilderDelegate delegate;

    if (!_hasSpoilers) {
      final tags = ctrl.model!.info.tags;

      delegate = SliverChildBuilderDelegate(
        (_, i) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            final explorable = Get.find<ExploreController>();
            explorable.clearAllFilters(update: false);
            explorable.setFilterWithKey(
              Filterable.SORT,
              value: describeEnum(MediaSort.TRENDING_DESC),
            );
            explorable.setFilterWithKey(
              Filterable.TAG_IN,
              value: [tags[i].name],
            );
            explorable.type = ctrl.model!.info.type;
            explorable.search = '';
            Get.find<HomeController>().homeTab = HomeView.EXPLORE;
            Navigator.popUntil(context, (r) => r.isFirst);
          },
          onLongPress: () => showPopUp(
            context,
            TextDialog(title: tags[i].name, text: tags[i].desciption),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: Config.BORDER_RADIUS,
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    tags[i].name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '${tags[i].rank} %',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ],
            ),
          ),
        ),
        childCount: tags.length,
      );
    } else {
      final tags = ctrl.showSpoilerTags
          ? ctrl.model!.info.tags
          : ctrl.model!.info.tags.where((t) => !t.isSpoiler).toList();

      final spoilerStyle = Theme.of(context)
          .textTheme
          .bodyText2!
          .copyWith(color: Theme.of(context).colorScheme.error);

      delegate = SliverChildBuilderDelegate(
        (_, i) {
          if (i == tags.length)
            return TextButton.icon(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.surface,
                ),
              ),
              onPressed: () => setState(
                () => ctrl.showSpoilerTags = !ctrl.showSpoilerTags,
              ),
              icon: Icon(ctrl.showSpoilerTags
                  ? Ionicons.eye_off_outline
                  : Ionicons.eye_outline),
              label: Text('Spoilers'),
            );

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              final explorable = Get.find<ExploreController>();
              explorable.clearAllFilters(update: false);
              explorable.setFilterWithKey(
                Filterable.SORT,
                value: describeEnum(MediaSort.TRENDING_DESC),
              );
              explorable.setFilterWithKey(
                Filterable.TAG_IN,
                value: [tags[i].name],
              );
              explorable.type = ctrl.model!.info.type;
              explorable.search = '';
              Get.find<HomeController>().homeTab = HomeView.EXPLORE;
              Navigator.popUntil(context, (r) => r.isFirst);
            },
            onLongPress: () => showPopUp(
              context,
              TextDialog(title: tags[i].name, text: tags[i].desciption),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: Config.BORDER_RADIUS,
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      tags[i].name,
                      style: tags[i].isSpoiler ? spoilerStyle : null,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${tags[i].rank} %',
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                ],
              ),
            ),
          );
        },
        childCount: tags.length + 1,
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
          height: Config.MATERIAL_TAP_TARGET_SIZE,
          minWidth: 175,
        ),
        delegate: delegate,
      ),
    );
  }
}
