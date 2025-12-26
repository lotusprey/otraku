import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/extension/build_context_extension.dart';
import 'package:otraku/extension/card_extension.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/feature/media/media_route_tile.dart';
import 'package:otraku/feature/studio/studio_floating_actions.dart';
import 'package:otraku/feature/studio/studio_header.dart';
import 'package:otraku/feature/studio/studio_model.dart';
import 'package:otraku/feature/studio/studio_provider.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/util/paged_controller.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/grid/sliver_grid_delegates.dart';
import 'package:otraku/widget/layout/adaptive_scaffold.dart';
import 'package:otraku/widget/layout/constrained_view.dart';
import 'package:otraku/widget/layout/hiding_floating_action_button.dart';
import 'package:otraku/widget/loaders.dart';
import 'package:otraku/widget/text_rail.dart';

class StudioView extends ConsumerStatefulWidget {
  const StudioView(this.id, this.name);

  final int id;
  final String? name;

  @override
  ConsumerState<StudioView> createState() => _StudioViewState();
}

class _StudioViewState extends ConsumerState<StudioView> {
  late final _scrollCtrl = PagedController(
    loadMore: () {
      ref.read(studioMediaProvider(widget.id).notifier).fetch();
    },
  );

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        ref.listen<AsyncValue>(
          studioMediaProvider(widget.id),
          (_, s) =>
              s.whenOrNull(error: (error, _) => SnackBarExtension.show(context, error.toString())),
        );

        final studio = ref.watch(studioProvider(widget.id)).value;
        final studioMedia = ref.watch(studioMediaProvider(widget.id));
        final options = ref.watch(persistenceProvider.select((s) => s.options));

        final mediaQuery = MediaQuery.of(context);

        final header = StudioHeader(
          id: widget.id,
          name: studio?.name ?? widget.name,
          studio: studio,
          toggleFavorite: () => ref.read(studioProvider(widget.id).notifier).toggleFavorite(),
        );

        final content = studioMedia.unwrapPrevious().when(
          loading: () => CustomScrollView(
            physics: Theming.bouncyPhysics,
            slivers: [
              header,
              const SliverFillRemaining(child: Center(child: Loader())),
            ],
          ),
          error: (_, _) => CustomScrollView(
            physics: Theming.bouncyPhysics,
            slivers: [
              header,
              const SliverFillRemaining(child: Center(child: Text('Failed to load studio'))),
            ],
          ),
          data: (data) => CustomScrollView(
            physics: Theming.bouncyPhysics,
            controller: _scrollCtrl,
            slivers: [
              header,
              MediaQuery(
                data: mediaQuery.copyWith(padding: mediaQuery.padding.copyWith(top: 0)),
                child: SliverRefreshControl(
                  onRefresh: () {
                    ref.invalidate(studioProvider(widget.id));
                    ref.invalidate(studioMediaProvider(widget.id));
                  },
                ),
              ),
              SliverConstrainedView(sliver: _StudioMediaGrid(data.items, options.highContrast)),
              SliverFooter(loading: data.hasNext),
            ],
          ),
        );

        return AdaptiveScaffold(
          floatingAction: studio != null
              ? HidingFloatingActionButton(
                  key: const Key('filter'),
                  scrollCtrl: _scrollCtrl,
                  child: StudioFilterButton(widget.id, ref),
                )
              : null,
          child: content,
        );
      },
    );
  }
}

class _StudioMediaGrid extends StatelessWidget {
  const _StudioMediaGrid(this.items, this.highContrast);

  final List<StudioMedia> items;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    final bodyMediumLineHeight = context.lineHeight(textTheme.bodyMedium!);
    final labelMediumLineHeight = context.lineHeight(textTheme.labelMedium!);
    final labelSmallLineHeight = context.lineHeight(textTheme.labelSmall!);
    final tileHeight =
        bodyMediumLineHeight * 2 + labelMediumLineHeight + max(labelSmallLineHeight, 15) + 20;
    final coverWidth = tileHeight / Theming.coverHtoWRatio;

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMinWidthAndFixedHeight(minWidth: 260, height: tileHeight),
      delegate: SliverChildBuilderDelegate(
        childCount: items.length,
        (context, i) => _MediaTile(items[i], highContrast, coverWidth),
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile(this.item, this.highContrast, this.coverWidth);

  final StudioMedia item;
  final bool highContrast;
  final double coverWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final textRailItems = <String, bool>{
      if (item.format != null) item.format!.label: false,
      if (item.entryStatus != null) item.entryStatus!.label(true): true,
      if (item.releaseStatus != null) item.releaseStatus!.label: false,
    };

    return MediaRouteTile(
      id: item.id,
      imageUrl: item.cover,
      child: CardExtension.highContrast(highContrast)(
        child: Row(
          mainAxisAlignment: .start,
          children: [
            Hero(
              tag: item.id,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Theming.radiusSmall),
                child: DecoratedBox(
                  decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest),
                  child: CachedImage(item.cover, width: coverWidth),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: .symmetric(horizontal: Theming.offset, vertical: 5),
                child: Column(
                  crossAxisAlignment: .start,
                  mainAxisAlignment: .spaceEvenly,
                  spacing: 5,
                  children: [
                    Flexible(child: Text(item.title, overflow: .ellipsis, maxLines: 2)),
                    TextRail(textRailItems, style: theme.textTheme.labelMedium),
                    if (item.startDate != null)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.startDate!,
                              style: theme.textTheme.labelSmall!.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisSize: .min,
                              spacing: 5,
                              children: [
                                Icon(
                                  Icons.percent_rounded,
                                  size: 15,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                Text(
                                  item.weightedAverageScore.toString(),
                                  style: theme.textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
