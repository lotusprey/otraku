import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/action_chip_extension.dart';
import 'package:otraku/extension/card_extension.dart';
import 'package:otraku/feature/discover/discover_filter_model.dart';
import 'package:otraku/feature/media/media_provider.dart';
import 'package:otraku/feature/tag/tag_model.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/html_content.dart';
import 'package:otraku/widget/loaders.dart';
import 'package:otraku/widget/table_list.dart';
import 'package:otraku/feature/discover/discover_filter_provider.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/widget/dialogs.dart';
import 'package:otraku/extension/snack_bar_extension.dart';

class MediaOverviewSubview extends StatelessWidget {
  const MediaOverviewSubview.asFragment({
    required this.info,
    required this.ref,
    required this.highContrast,
    required ScrollController this.scrollCtrl,
  }) : header = null;

  const MediaOverviewSubview.withHeader({
    required this.info,
    required this.ref,
    required this.highContrast,
    required Widget this.header,
  }) : scrollCtrl = null;

  final WidgetRef ref;
  final MediaInfo info;
  final Widget? header;
  final ScrollController? scrollCtrl;
  final bool highContrast;

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
      if (info.status != null) ('Status', info.status!.label),
      if (info.episodes != null) ('Episodes', info.episodes!.toString()),
      if (info.duration != null) ('Duration', info.duration!),
      if (info.chapters != null) ('Chapters', info.chapters!.toString()),
      if (info.volumes != null) ('Volumes', info.volumes!.toString()),
      if (info.season != null) ('Season', info.season!),
      if (info.source != null) ('Source', info.source!.label),
      if (info.countryOfOrigin != null) ('Origin', info.countryOfOrigin!.label),
    ];

    final titles = [
      if (info.hashtag != null) ('Hashtag', info.hashtag!),
      if (info.romajiTitle != null) ('Romaji', info.romajiTitle!),
      if (info.englishTitle != null) ('English', info.englishTitle!),
      if (info.nativeTitle != null) ('Native', info.nativeTitle!),
      ...info.synonyms.map((s) => ('Synonym', s)),
    ];

    const spacing = SliverToBoxAdapter(child: SizedBox(height: Theming.offset));
    final mediaQuery = MediaQuery.of(context);
    final refreshControl = SliverRefreshControl(
      onRefresh: () => ref.invalidate(mediaProvider(info.id)),
    );

    return CustomScrollView(
      controller: scrollCtrl,
      physics: Theming.bouncyPhysics,
      slivers: [
        if (header != null) ...[
          header!,
          MediaQuery(
            data: mediaQuery.copyWith(padding: mediaQuery.padding.copyWith(top: 0)),
            child: refreshControl,
          ),
        ] else
          refreshControl,
        SliverPadding(
          padding: const .symmetric(horizontal: Theming.offset),
          sliver: SliverMainAxisGroup(
            slivers: [
              if (info.description.isNotEmpty) _Description(info.description, highContrast),
              SliverToBoxAdapter(
                child: CardExtension.highContrast(highContrast)(
                  child: Padding(
                    padding: Theming.paddingAll,
                    child: Row(
                      mainAxisAlignment: .spaceEvenly,
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
              SliverTableList(details, highContrast: highContrast),
              if (info.genres.isNotEmpty)
                _Wrap(
                  title: 'Genres',
                  children: info.genres
                      .map((genre) => _buildGenreActionChip(context, genre, highContrast))
                      .toList(),
                ),
              if (info.tags.isNotEmpty)
                _TagsWrap(
                  ref: ref,
                  tags: info.tags,
                  isAnime: info.isAnime,
                  highContrast: highContrast,
                ),
              if (info.studios.isNotEmpty)
                _Wrap(
                  title: 'Studios',
                  children: info.studios.entries
                      .map(
                        (studio) =>
                            _buildStudioActionChip(context, studio.key, studio.value, highContrast),
                      )
                      .toList(),
                ),
              if (info.producers.isNotEmpty)
                _Wrap(
                  title: 'Producers',
                  children: info.producers.entries
                      .map(
                        (studio) =>
                            _buildStudioActionChip(context, studio.key, studio.value, highContrast),
                      )
                      .toList(),
                ),
              if (info.externalLinks.isNotEmpty)
                _Wrap(
                  title: 'External links',
                  children: info.externalLinks
                      .map((link) => _buildExternalLinkChip(context, link, highContrast))
                      .toList(),
                ),
              spacing,
              spacing,
              SliverTableList(titles, highContrast: highContrast),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.paddingOf(context).bottom + Theming.normalTapTarget + 26,
          ),
        ),
      ],
    );
  }

  Widget _buildGenreActionChip(BuildContext context, String genre, bool highContrast) {
    return ActionChipExtension.highContrast(highContrast)(
      label: Text(genre),
      tooltip: 'Filter By Genre',
      onPressed: () {
        final notifier = ref.read(discoverFilterProvider.notifier);
        final filter = notifier.state.copyWith(
          type: info.isAnime ? .anime : .manga,
          search: '',
          mediaFilter: DiscoverMediaFilter(notifier.state.mediaFilter.sort),
        )..mediaFilter.genreIn.add(genre);
        notifier.state = filter;

        context.go(Routes.home(.discover));
      },
    );
  }

  Widget _buildStudioActionChip(BuildContext context, String name, int id, bool highContrast) {
    return ActionChipExtension.highContrast(highContrast)(
      label: Text(name),
      tooltip: 'Open Studio',
      onPressed: () => context.push(Routes.studio(id, name)),
    );
  }

  Widget _buildExternalLinkChip(BuildContext context, ExternalLink link, bool highContrast) {
    return _Chip(
      label: link.countryCode == null ? Text(link.site) : Text('${link.site} ${link.countryCode}'),
      onTap: () => SnackBarExtension.launch(context, link.url),
      onLongTap: () => SnackBarExtension.copy(context, link.url),
      onTapHint: 'open external link',
      onLongTapHint: 'copy external link',
      highContrast: highContrast,
      leading: Container(
        width: 15,
        height: 15,
        decoration: BoxDecoration(borderRadius: Theming.borderRadiusSmall, color: link.color),
      ),
    );
  }
}

class _Description extends StatefulWidget {
  const _Description(this.text, this.highContrast);

  final String text;
  final bool highContrast;

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
              begin: Alignment(0.0, 0.5),
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
        padding: const .only(bottom: Theming.offset),
        child: CardExtension.highContrast(widget.highContrast)(
          child: InkWell(
            borderRadius: Theming.borderRadiusSmall,
            onTap: () => setState(() => _expanded = !_expanded),
            onLongPress: () {
              final text = widget.text.replaceAll(RegExp(r'<br>'), '');
              SnackBarExtension.copy(context, text);
            },
            child: Padding(padding: const .all(Theming.offset), child: content),
          ),
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.text, required this.tooltip, required this.icon});

  final String text;
  final String tooltip;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      triggerMode: .tap,
      child: Column(
        mainAxisSize: .min,
        spacing: 5,
        children: [
          Icon(icon, size: Theming.iconSmall, color: ColorScheme.of(context).onSurfaceVariant),
          Text(text),
        ],
      ),
    );
  }
}

class _Wrap extends StatelessWidget {
  const _Wrap({required this.title, required this.children, this.trailingAction});

  final String title;
  final Widget? trailingAction;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(title)),
              if (trailingAction != null)
                trailingAction!
              else
                const SizedBox(height: Theming.minTapTarget),
            ],
          ),
          Wrap(spacing: 5, children: children),
        ],
      ),
    );
  }
}

class _TagsWrap extends StatefulWidget {
  const _TagsWrap({
    required this.ref,
    required this.tags,
    required this.isAnime,
    required this.highContrast,
  });

  final WidgetRef ref;
  final List<Tag> tags;
  final bool isAnime;
  final bool highContrast;

  @override
  State<_TagsWrap> createState() => __TagsWrapState();
}

class __TagsWrapState extends State<_TagsWrap> {
  bool? _showSpoilers;

  @override
  void initState() {
    super.initState();
    for (final t in widget.tags) {
      if (t.isSpoiler) {
        _showSpoilers = false;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tags = _showSpoilers == null || _showSpoilers!
        ? widget.tags
        : widget.tags.where((t) => !t.isSpoiler).toList();

    final spoilerColor = ColorScheme.of(context).error;

    return _Wrap(
      title: 'Tags',
      trailingAction: _showSpoilers != null
          ? IconButton(
              icon: _showSpoilers!
                  ? const Icon(Ionicons.eye_off_outline)
                  : const Icon(Ionicons.eye_outline),
              tooltip: _showSpoilers! ? 'Hide Spoilers' : 'Show Spoilers',
              onPressed: () => setState(() => _showSpoilers = !_showSpoilers!),
            )
          : null,
      children: tags.map((tag) => _buildTagChip(tag, spoilerColor)).toList(),
    );
  }

  Widget _buildTagChip(Tag tag, Color spoilerColor) {
    return _Chip(
      label: Text(
        '${tag.name} ${tag.rank}%',
        style: tag.isSpoiler ? TextStyle(color: spoilerColor) : null,
      ),
      onTapHint: 'filter by this tag',
      onLongTapHint: 'show tag description',
      highContrast: widget.highContrast,
      onTap: () {
        final notifier = widget.ref.read(discoverFilterProvider.notifier);
        final filter = notifier.state.copyWith(
          type: widget.isAnime ? .anime : .manga,
          search: '',
          mediaFilter: DiscoverMediaFilter(notifier.state.mediaFilter.sort),
        )..mediaFilter.tagIn.add(tag.name);
        notifier.state = filter;

        context.go(Routes.home(.discover));
      },
      onLongTap: () => showDialog(
        context: context,
        builder: (context) => TextDialog(title: tag.name, text: tag.desciption),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.highContrast,
    this.leading,
    this.onTap,
    this.onLongTap,
    this.onTapHint,
    this.onLongTapHint,
  });

  final Widget label;
  final Widget? leading;
  final void Function()? onTap;
  final void Function()? onLongTap;
  final String? onTapHint;
  final String? onLongTapHint;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        onTapHint: onTapHint,
        onLongPressHint: onLongTapHint,
        child: GestureDetector(
          onLongPress: onLongTap,
          child: ActionChipExtension.highContrast(highContrast)(
            label: label,
            avatar: leading,
            onPressed: onTap,
          ),
        ),
      ),
    );
  }
}
