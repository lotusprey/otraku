import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/build_context_extension.dart';
import 'package:otraku/extension/date_time_extension.dart';
import 'package:otraku/feature/discover/discover_models.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/overlays/dialogs.dart';
import 'package:otraku/widget/overlays/sheets.dart';
import 'package:otraku/util/toast.dart';
import 'package:otraku/widget/text_rail.dart';

class MediaHeader extends StatelessWidget {
  const MediaHeader({
    required this.id,
    required this.coverUrl,
    required this.media,
    required this.tabCtrl,
    required this.scrollToTop,
  });

  final int id;
  final String? coverUrl;
  final Media? media;
  final TabController tabCtrl;
  final void Function() scrollToTop;

  @override
  Widget build(BuildContext context) {
    final topOffset = MediaQuery.paddingOf(context).top;
    final textRailItems = <String, bool>{};

    if (media != null) {
      final info = media!.info;

      if (info.isAdult) textRailItems['Adult'] = true;

      if (info.format != null) {
        textRailItems[info.format!.label] = false;
      }

      if (media!.edit.status != null) {
        textRailItems[media!.edit.status!.label(
          info.type == DiscoverType.anime,
        )] = false;
      }

      if (info.airingAt != null) {
        textRailItems['Ep ${info.nextEpisode} in '
            '${info.airingAt!.timeUntil}'] = true;
      }

      if (media!.edit.status != null) {
        final progress = media!.edit.progress;
        if (info.nextEpisode != null && info.nextEpisode! - 1 > progress) {
          textRailItems['${info.nextEpisode! - 1 - progress}'
              ' ep behind'] = true;
        }
      }
    }

    final size = MediaQuery.sizeOf(context);

    return SliverPersistentHeader(
      pinned: true,
      delegate: _Delegate(
        id: id,
        tabCtrl: tabCtrl,
        info: media?.info,
        coverUrl: coverUrl,
        topOffset: topOffset,
        scrollToTop: scrollToTop,
        textRailItems: textRailItems,
        imageWidth: size.width < 430.0 ? size.width * 0.30 : 100.0,
      ),
    );
  }
}

class _Delegate extends SliverPersistentHeaderDelegate {
  _Delegate({
    required this.id,
    required this.info,
    required this.imageWidth,
    required this.coverUrl,
    required this.topOffset,
    required this.textRailItems,
    required this.scrollToTop,
    required this.tabCtrl,
  });

  final int id;
  final MediaInfo? info;
  final double imageWidth;
  final String? coverUrl;
  final double topOffset;
  final Map<String, bool> textRailItems;
  final TabController tabCtrl;
  final void Function() scrollToTop;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final height = maxExtent;
    final bannerOffset =
        height - _bannerBaseHeight - topOffset - imageHeight / 4;

    var transition = shrinkOffset > _bannerBaseHeight
        ? (shrinkOffset - _bannerBaseHeight) / (imageHeight / 4)
        : 0.0;
    if (transition > 1) transition = 1;

    final cover = info?.cover ?? coverUrl;
    final theme = Theme.of(context);

    final infoContent = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Hero(
          tag: id,
          child: ClipRRect(
            borderRadius: Theming.borderRadiusSmall,
            child: Container(
              height: imageHeight,
              width: imageWidth,
              color: theme.colorScheme.surfaceContainerHighest,
              child: cover != null
                  ? GestureDetector(
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) =>
                            ImageDialog(info?.extraLargeCover ?? cover),
                      ),
                      child: CachedImage(cover),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(width: Theming.offset),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (info?.preferredTitle != null) ...[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Toast.copy(context, info!.preferredTitle!),
                  child: Text(
                    info!.preferredTitle!,
                    maxLines: 8,
                    overflow: TextOverflow.fade,
                    style: theme.textTheme.titleLarge!.copyWith(
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: theme.colorScheme.surface,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 5),
              ],
              TextRail(
                textRailItems,
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ],
    );

    final topRow = Row(
      children: [
        IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: context.back,
        ),
        Expanded(
          child: info?.preferredTitle == null
              ? const SizedBox()
              : Opacity(
                  opacity: transition,
                  child: Text(
                    info!.preferredTitle!,
                    style: theme.textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
        ),
        if (info?.siteUrl != null)
          IconButton(
            tooltip: 'More',
            icon: const Icon(Ionicons.ellipsis_horizontal),
            onPressed: () => showSheet(
              context,
              SimpleSheet.link(context, info!.siteUrl!),
            ),
          ),
      ],
    );

    final body = SizedBox(
      height: height,
      child: Column(
        children: [
          Flexible(
            flex: (height - Theming.minTapTarget).floor(),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (transition < 1) ...[
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: bannerOffset,
                    child: info?.banner != null
                        ? GestureDetector(
                            child: CachedImage(info!.banner!),
                            onTap: () => showDialog(
                              context: context,
                              builder: (context) => ImageDialog(info!.banner!),
                            ),
                          )
                        : DecoratedBox(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                            ),
                          ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: bannerOffset,
                    child: Container(
                      alignment: Alignment.topCenter,
                      color: theme.colorScheme.surface,
                      child: Container(
                        height: 0,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 15,
                              spreadRadius: 25,
                              color: theme.colorScheme.surface,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    left: Theming.offset,
                    right: Theming.offset,
                    child: infoContent,
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: topOffset + Theming.minTapTarget,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.colorScheme.surface,
                            theme.colorScheme.surface.withAlpha(200),
                            theme.colorScheme.surface.withAlpha(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: topOffset + Theming.minTapTarget,
                    child: Opacity(
                      opacity: transition,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                        ),
                      ),
                    ),
                  ),
                ],
                Positioned(
                  left: 0,
                  right: 0,
                  top: topOffset,
                  height: Theming.minTapTarget,
                  child: topRow,
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: TabBar(
              tabAlignment: TabAlignment.center,
              splashBorderRadius: Theming.borderRadiusSmall,
              controller: tabCtrl,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Related'),
                Tab(text: 'Characters'),
                Tab(text: 'Staff'),
                Tab(text: 'Reviews'),
                Tab(text: 'Following'),
                Tab(text: 'Recommendations'),
                Tab(text: 'Statistics'),
              ],
              onTap: (i) {
                if (i == tabCtrl.index) {
                  scrollToTop();
                }
              },
            ),
          ),
        ],
      ),
    );

    return transition < 1
        ? body
        : ClipRect(
            child: BackdropFilter(
              filter: Theming.blurFilter,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).navigationBarTheme.backgroundColor,
                ),
                child: body,
              ),
            ),
          );
  }

  static const _bannerBaseHeight = 200.0;

  double get imageHeight => imageWidth * Theming.coverHtoWRatio;

  @override
  double get minExtent => topOffset + Theming.minTapTarget * 2;

  @override
  double get maxExtent =>
      topOffset + Theming.minTapTarget + _bannerBaseHeight + imageHeight / 2;

  @override
  bool shouldRebuild(covariant _Delegate oldDelegate) =>
      info != oldDelegate.info;
}
