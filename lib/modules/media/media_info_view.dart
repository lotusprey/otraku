import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/common/utils/routing.dart';
import 'package:otraku/common/widgets/html_content.dart';
import 'package:otraku/common/widgets/layouts/floating_bar.dart';
import 'package:otraku/common/widgets/shadowed_overflow_list.dart';
import 'package:otraku/modules/discover/discover_filter_provider.dart';
import 'package:otraku/modules/filter/filter_models.dart';
import 'package:otraku/modules/home/home_model.dart';
import 'package:otraku/modules/media/media_models.dart';
import 'package:otraku/common/widgets/overlays/dialogs.dart';
import 'package:otraku/common/utils/toast.dart';

class MediaInfoView extends StatelessWidget {
  const MediaInfoView(this.info, this.scrollCtrl);

  final MediaInfo info;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    String? release;
    if (info.startDate != null) {
      if (info.endDate != null) {
        if (info.startDate != info.endDate) {
          release = '${info.startDate} - ${info.endDate}';
        } else {
          release = info.startDate!;
        }
      } else {
        release = '${info.startDate} - ?';
      }
    }

    final details = [
      if (release != null) ('Release', release),
      if (info.status != null) ('Status', info.status!),
      if (info.episodes != null) ('Episodes', info.episodes!.toString()),
      if (info.duration != null) ('Duration', info.duration!),
      if (info.chapters != null) ('Chapters', info.chapters!.toString()),
      if (info.volumes != null) ('Volumes', info.volumes!.toString()),
      if (info.season != null) ('Season', info.season!),
      if (info.source != null) ('Source', info.source!),
      if (info.countryOfOrigin != null) ('Origin', info.countryOfOrigin!.label),
    ];

    final titles = [
      if (info.hashtag != null) ('Hashtag', info.hashtag!),
      if (info.romajiTitle != null) ('Romaji', info.romajiTitle!),
      if (info.englishTitle != null) ('English', info.englishTitle!),
      if (info.nativeTitle != null) ('Native', info.nativeTitle!),
      if (info.synonyms.isNotEmpty) ('Synonyms', info.synonyms.join('\n')),
    ];

    const spacing = SliverToBoxAdapter(child: SizedBox(height: 10));

    return Consumer(
      builder: (context, ref, _) => CustomScrollView(
        controller: scrollCtrl,
        slivers: [
          if (info.description.isNotEmpty)
            _Description(info.description)
          else
            spacing,
          SliverToBoxAdapter(
            child: Card.outlined(
              child: Padding(
                padding: Consts.padding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _IconTile(
                      text: info.favourites.toString(),
                      tooltip: 'Favorites',
                      icon: Icons.favorite_outline_rounded,
                    ),
                    _IconTile(
                      text: info.popularity.toString(),
                      tooltip: 'Popularity',
                      icon: Icons.person_outline_rounded,
                    ),
                    _IconTile(
                      text: info.averageScore.toString(),
                      tooltip: 'Weighted Average Score',
                      icon: Icons.percent_rounded,
                    ),
                    _IconTile(
                      text: info.meanScore.toString(),
                      tooltip: 'Mean Score',
                      icon: Ionicons.star_half_outline,
                    ),
                  ],
                ),
              ),
            ),
          ),
          spacing,
          _Rows(details),
          spacing,
          if (info.genres.isNotEmpty)
            _PlainScrollCards(
              title: 'Genres',
              items: info.genres,
              onTap: (i) {
                final notifier = ref.read(discoverFilterProvider.notifier);
                final filter = notifier.state.copyWith(
                  type: info.type,
                  search: '',
                  mediaFilter: DiscoverMediaFilter(),
                )..mediaFilter.genreIn.add(info.genres[i]);
                notifier.state = filter;

                context.go(Routes.home(HomeTab.discover));
              },
            ),
          if (info.tags.isNotEmpty) ...[_TagScrollCards(info, ref), spacing],
          if (info.studios.isNotEmpty) ...[
            _PlainScrollCards(
              title: 'Studios',
              items: info.studios.keys.toList(),
              onTap: (i) => context.push(
                Routes.studio(
                  info.studios.values.elementAt(i),
                  info.studios.keys.elementAt(i),
                ),
              ),
            ),
            spacing,
          ],
          if (info.producers.isNotEmpty) ...[
            _PlainScrollCards(
              title: 'Producers',
              items: info.producers.keys.toList(),
              onTap: (i) => context.push(
                Routes.studio(
                  info.producers.values.elementAt(i),
                  info.producers.keys.elementAt(i),
                ),
              ),
            ),
            spacing,
          ],
          if (info.externalLinks.isNotEmpty) ...[
            _ExternalLinkScrollCards(info.externalLinks),
            spacing,
          ],
          _Rows(titles),
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.paddingOf(context).bottom +
                  floatingBarItemHeight +
                  26,
            ),
          ),
        ],
      ),
    );
  }
}

class _Description extends StatefulWidget {
  const _Description(this.text);

  final String text;

  @override
  State<_Description> createState() => _DescriptionState();
}

class _DescriptionState extends State<_Description> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final content = _expanded
        ? HtmlContent(widget.text)
        : ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment(0.0, 0.7),
              end: Alignment(0.0, 1.0),
              colors: [Colors.white, Colors.transparent],
            ).createShader(bounds),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 72),
              child: HtmlContent(widget.text),
            ),
          );

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Card.outlined(
          child: InkWell(
            borderRadius: Consts.borderRadiusMin,
            onTap: () => setState(() => _expanded = !_expanded),
            onLongPress: () {
              final text = widget.text.replaceAll(RegExp(r'<br>'), '');
              Toast.copy(context, text);
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.text,
    required this.tooltip,
    required this.icon,
  });

  final String text;
  final String tooltip;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: Consts.iconSmall,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 5),
          Text(text),
        ],
      ),
    );
  }
}

class _Rows extends StatelessWidget {
  const _Rows(this.items);

  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    return DecoratedSliver(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceVariant,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      sliver: SliverPadding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        sliver: SliverList.separated(
          itemCount: items.length,
          separatorBuilder: (context, _) => const Divider(),
          itemBuilder: (context, i) => Row(
            children: [
              const SizedBox(width: 10),
              Text(items[i].$1),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Toast.copy(context, items[i].$2),
                  child: Text(items[i].$2, textAlign: TextAlign.end),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScrollCards extends StatelessWidget {
  const _ScrollCards({
    required this.title,
    required this.itemCount,
    required this.builder,
    required this.onTap,
    required this.onLongPress,
    this.trailingAction,
  });

  final String title;
  final int itemCount;
  final Widget Function(BuildContext, int) builder;
  final void Function(int) onTap;
  final void Function(int) onLongPress;
  final Widget? trailingAction;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(title),
              const Spacer(),
              if (trailingAction != null) trailingAction!,
            ],
          ),
          if (trailingAction == null) const SizedBox(height: 10),
          SizedBox(
            height: 42,
            child: ShadowedOverflowList(
              itemCount: itemCount,
              itemBuilder: (context, i) => Card(
                margin: const EdgeInsets.only(bottom: 2),
                child: InkWell(
                  borderRadius: Consts.borderRadiusMin,
                  onTap: () => onTap(i),
                  onLongPress: () => onLongPress(i),
                  child: Padding(
                    padding: Consts.padding,
                    child: builder(context, i),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlainScrollCards extends StatelessWidget {
  const _PlainScrollCards({
    required this.title,
    required this.items,
    required this.onTap,
  });

  final String title;
  final List<String> items;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return _ScrollCards(
      title: title,
      itemCount: items.length,
      onTap: onTap,
      onLongPress: (i) => Toast.copy(context, items[i]),
      builder: (context, i) => Text(items[i]),
    );
  }
}

class _TagScrollCards extends StatefulWidget {
  const _TagScrollCards(this.info, this.ref);

  final MediaInfo info;
  final WidgetRef ref;

  @override
  State<_TagScrollCards> createState() => _TagScrollCardsState();
}

class _TagScrollCardsState extends State<_TagScrollCards> {
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
    final tags = _showSpoilers == null || _showSpoilers!
        ? widget.info.tags
        : widget.info.tags.where((t) => !t.isSpoiler).toList();

    final spoilerTextStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: Theme.of(context).colorScheme.error);

    return _ScrollCards(
      title: 'Tags',
      itemCount: tags.length,
      onTap: (i) {
        final notifier = widget.ref.read(discoverFilterProvider.notifier);
        final filter = notifier.state.copyWith(
          type: widget.info.type,
          search: '',
          mediaFilter: DiscoverMediaFilter(),
        )..mediaFilter.tagIn.add(tags[i].name);
        notifier.state = filter;

        context.go(Routes.home(HomeTab.discover));
      },
      onLongPress: (i) => showPopUp(
        context,
        TextDialog(title: tags[i].name, text: tags[i].desciption),
      ),
      trailingAction: _showSpoilers != null
          ? IconButton(
              icon: _showSpoilers!
                  ? const Icon(Ionicons.eye_off_outline)
                  : const Icon(Ionicons.eye_outline),
              tooltip: _showSpoilers! ? 'Hide Spoilers' : 'Show Spoilers',
              onPressed: () => setState(() => _showSpoilers = !_showSpoilers!),
            )
          : null,
      builder: (context, i) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tags[i].name,
            style: tags[i].isSpoiler ? spoilerTextStyle : null,
          ),
          const SizedBox(width: 5),
          Text(
            '${tags[i].rank}%',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

class _ExternalLinkScrollCards extends StatelessWidget {
  const _ExternalLinkScrollCards(this.items);

  final List<ExternalLink> items;

  @override
  Widget build(BuildContext context) {
    return _ScrollCards(
      title: "External Links",
      itemCount: items.length,
      onTap: (i) => Toast.launch(context, items[i].url),
      onLongPress: (i) => Toast.copy(context, items[i].url),
      builder: (context, i) => Row(
        children: [
          if (items[i].color != null)
            Container(
              padding: Consts.padding,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                borderRadius: Consts.borderRadiusMin,
                color: items[i].color,
              ),
            ),
          Text(items[i].site),
          if (items[i].countryCode != null) ...[
            const SizedBox(width: 5),
            Text(
              items[i].countryCode!,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ],
      ),
    );
  }
}
