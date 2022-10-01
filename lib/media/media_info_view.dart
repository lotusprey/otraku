import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/discover/discover_models.dart';
import 'package:otraku/discover/discover_providers.dart';
import 'package:otraku/edit/edit_view.dart';
import 'package:otraku/filter/filter_providers.dart';
import 'package:otraku/home/home_provider.dart';
import 'package:otraku/home/home_view.dart';
import 'package:otraku/media/media_models.dart';
import 'package:otraku/media/media_providers.dart';
import 'package:otraku/widgets/link_tile.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';
import 'package:otraku/widgets/overlays/toast.dart';

class MediaInfoView extends StatelessWidget {
  const MediaInfoView(this.media);

  final Media media;

  @override
  Widget build(BuildContext context) {
    final info = media.info;

    final infoTitles = [
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
      'Origin',
    ];

    final infoData = [
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

    for (int i = infoData.length - 1; i >= 0; i--) {
      if (infoData[i] == null) {
        infoData.removeAt(i);
        infoTitles.removeAt(i);
      }
    }

    final scrollCtrl = context
        .findAncestorStateOfType<NestedScrollViewState>()!
        .innerController;

    return Consumer(
      builder: (context, ref, _) => PageLayout(
        floatingBar: FloatingBar(
          scrollCtrl: scrollCtrl,
          children: [_EditButton(media), _FavoriteButton(info)],
        ),
        child: CustomScrollView(
          controller: scrollCtrl,
          slivers: [
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            if (info.description.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: Consts.padding,
                  child: GestureDetector(
                    child: Card(
                      child: Padding(
                        padding: Consts.padding,
                        child: Text(
                          info.description,
                          maxLines: 4,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ),
                    onTap: () => showPopUp(
                      context,
                      TextDialog(title: 'Description', text: info.description),
                    ),
                  ),
                ),
              )
            else
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverPadding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              sliver: SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithMinWidthAndFixedHeight(
                  height: Consts.tapTargetSize,
                  minWidth: 130,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            infoTitles[i],
                            maxLines: 1,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          Text(infoData[i].toString(), maxLines: 1),
                        ],
                      ),
                    ),
                  ),
                  childCount: infoData.length,
                ),
              ),
            ),
            if (info.genres.isNotEmpty)
              _ScrollCards(
                title: 'Genres',
                items: info.genres,
                onTap: (i) {
                  ref.read(discoverTypeProvider.notifier).state = info.type;
                  ref.read(searchProvider(null).notifier).state = null;

                  final ofAnime = info.type == DiscoverType.anime;
                  final notifier = ref.read(
                    discoverFilterProvider(ofAnime).notifier,
                  );
                  final filter = notifier.state.clear();
                  filter.genreIn.add(info.genres[i]);
                  notifier.state = filter;

                  ref.read(homeProvider).homeTab = HomeView.DISCOVER;
                  Navigator.popUntil(context, (r) => r.isFirst);
                },
              ),
            if (info.studios.isNotEmpty)
              _ScrollCards(
                title: 'Studios',
                items: info.studios.keys.toList(),
                onTap: (index) => LinkTile.openView(
                  context: context,
                  id: info.studios[info.studios.keys.elementAt(index)]!,
                  imageUrl: info.studios.keys.elementAt(index),
                  discoverType: DiscoverType.studio,
                ),
              ),
            if (info.producers.isNotEmpty)
              _ScrollCards(
                title: 'Producers',
                items: info.producers.keys.toList(),
                onTap: (i) => LinkTile.openView(
                  context: context,
                  id: info.producers[info.producers.keys.elementAt(i)]!,
                  imageUrl: info.producers.keys.elementAt(i),
                  discoverType: DiscoverType.studio,
                ),
              ),
            if (info.hashtag != null) _Title('Hashtag', info.hashtag!),
            if (info.romajiTitle != null) _Title('Romaji', info.romajiTitle!),
            if (info.englishTitle != null)
              _Title('English', info.englishTitle!),
            if (info.nativeTitle != null) _Title('Native', info.nativeTitle!),
            if (info.synonyms.isNotEmpty)
              _Title('Synonyms', info.synonyms.join(', ')),
            if (info.tags.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                  child: Text(
                    'Tags',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
              ),
              _Tags(info, ref),
            ],
            const SliverFooter(),
          ],
        ),
      ),
    );
  }
}

class _EditButton extends StatefulWidget {
  const _EditButton(this.media);

  final Media media;

  @override
  State<_EditButton> createState() => __EditButtonState();
}

class __EditButtonState extends State<_EditButton> {
  @override
  Widget build(BuildContext context) {
    final media = widget.media;
    return ActionButton(
      icon: media.edit.status == null ? Icons.add : Icons.edit_outlined,
      tooltip: media.edit.status == null ? 'Add' : 'Edit',
      onTap: () => showSheet(
        context,
        EditView(
          media.info.id,
          edit: media.edit,
          callback: (edit) => setState(() => media.edit = edit),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton(this.info);

  final MediaInfo info;

  @override
  State<_FavoriteButton> createState() => __FavoriteButtonState();
}

class __FavoriteButtonState extends State<_FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    return ActionButton(
      icon: widget.info.isFavorite ? Icons.favorite : Icons.favorite_border,
      tooltip: widget.info.isFavorite ? 'Unfavourite' : 'Favourite',
      onTap: () {
        setState(() => widget.info.isFavorite = !widget.info.isFavorite);
        toggleFavoriteMedia(
          widget.info.id,
          widget.info.type == DiscoverType.anime,
        ).then((ok) {
          if (!ok) {
            setState(() => widget.info.isFavorite = !widget.info.isFavorite);
          }
        });
      },
    );
  }
}

class _ScrollCards extends StatelessWidget {
  const _ScrollCards({
    required this.title,
    required this.items,
    required this.onTap,
  });

  final String title;
  final List<String> items;
  final void Function(int) onTap;

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
                physics: Consts.physics,
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (_, index) => GestureDetector(
                  onTap: () => onTap(index),
                  onLongPress: () => Toast.copy(context, items[index]),
                  child: Card(
                    margin: const EdgeInsets.only(right: 10),
                    child: Padding(
                      padding: Consts.padding,
                      child: Text(items[index]),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.label, this.title);

  final String label;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 90,
              child: Text(label, style: Theme.of(context).textTheme.subtitle1),
            ),
            Flexible(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Toast.copy(context, title),
                child: Text(
                  title,
                  maxLines: null,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tags extends StatefulWidget {
  const _Tags(this.info, this.ref);

  final MediaInfo info;
  final WidgetRef ref;

  @override
  __TagsState createState() => __TagsState();
}

class __TagsState extends State<_Tags> {
  bool? _showSpoilers;

  @override
  void initState() {
    super.initState();
    for (final t in widget.info.tags) {
      if (t.isSpoiler) {
        _showSpoilers = false;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    late SliverChildBuilderDelegate delegate;

    if (_showSpoilers == null) {
      final tags = widget.info.tags;

      delegate = SliverChildBuilderDelegate(
        childCount: tags.length,
        (_, i) => Card(
          clipBehavior: Clip.hardEdge,
          child: InkResponse(
            onTap: () {
              final ref = widget.ref;
              ref.read(discoverTypeProvider.notifier).state = widget.info.type;
              ref.read(searchProvider(null).notifier).state = null;

              final ofAnime = widget.info.type == DiscoverType.anime;
              final notifier = ref.read(
                discoverFilterProvider(ofAnime).notifier,
              );
              final filter = notifier.state.clear();
              filter.tagIn.add(tags[i].name);
              notifier.state = filter;

              ref.read(homeProvider).homeTab = HomeView.DISCOVER;
              Navigator.popUntil(context, (r) => r.isFirst);
            },
            onLongPress: () => showPopUp(
              context,
              TextDialog(title: tags[i].name, text: tags[i].desciption),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
        ),
      );
    } else {
      final tags = _showSpoilers!
          ? widget.info.tags
          : widget.info.tags.where((t) => !t.isSpoiler).toList();

      final spoilerStyle = Theme.of(context)
          .textTheme
          .bodyText2!
          .copyWith(color: Theme.of(context).colorScheme.error);

      delegate = SliverChildBuilderDelegate(
        childCount: tags.length + 1,
        (_, i) {
          if (i == tags.length) {
            return ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
                shape: const RoundedRectangleBorder(
                  borderRadius: Consts.borderRadiusMin,
                ),
              ),
              onPressed: () => setState(() => _showSpoilers = !_showSpoilers!),
              icon: Icon(
                _showSpoilers!
                    ? Ionicons.eye_off_outline
                    : Ionicons.eye_outline,
              ),
              label: const Text('Spoilers'),
            );
          }

          return Card(
            clipBehavior: Clip.hardEdge,
            child: InkResponse(
              onTap: () {
                final ref = widget.ref;
                ref.read(discoverTypeProvider.notifier).state =
                    widget.info.type;
                ref.read(searchProvider(null).notifier).state = null;

                final ofAnime = widget.info.type == DiscoverType.anime;
                final notifier = ref.read(
                  discoverFilterProvider(ofAnime).notifier,
                );
                final filter = notifier.state.clear();
                filter.tagIn.add(tags[i].name);
                notifier.state = filter;

                ref.read(homeProvider).homeTab = HomeView.DISCOVER;
                Navigator.popUntil(context, (r) => r.isFirst);
              },
              onLongPress: () => showPopUp(
                context,
                TextDialog(title: tags[i].name, text: tags[i].desciption),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        tags[i].name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: tags[i].isSpoiler ? spoilerStyle : null,
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
          );
        },
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
      sliver: SliverGrid(
        delegate: delegate,
        gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
          height: Consts.tapTargetSize,
          minWidth: 175,
        ),
      ),
    );
  }
}
