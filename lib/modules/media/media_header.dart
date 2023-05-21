import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/modules/discover/discover_models.dart';
import 'package:otraku/modules/media/media_models.dart';
import 'package:otraku/modules/media/media_providers.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/common/utils/convert.dart';
import 'package:otraku/common/widgets/cached_image.dart';
import 'package:otraku/common/widgets/layouts/top_bar.dart';
import 'package:otraku/common/widgets/overlays/dialogs.dart';
import 'package:otraku/common/widgets/overlays/sheets.dart';
import 'package:otraku/common/widgets/overlays/toast.dart';
import 'package:otraku/common/widgets/text_rail.dart';

class MediaHeader extends StatelessWidget {
  const MediaHeader(this.id, this.coverUrl, this.tabCtrl);

  final int id;
  final String? coverUrl;
  final TabController tabCtrl;

  @override
  Widget build(BuildContext context) {
    final topOffset = MediaQuery.of(context).padding.top;

    return Consumer(
      builder: (context, ref, _) {
        final media = ref.watch(mediaProvider(id).select((s) => s.valueOrNull));
        final textRailItems = <String, bool>{};

        if (media != null) {
          final info = media.info;

          if (info.isAdult) textRailItems['Adult'] = true;

          if (info.format != null) {
            textRailItems[Convert.clarifyEnum(info.format)!] = false;
          }

          if (media.edit.status != null) {
            textRailItems[Convert.adaptListStatus(
              media.edit.status!,
              info.type == DiscoverType.anime,
            )] = false;
          }

          if (info.airingAt != null) {
            textRailItems['Ep ${info.nextEpisode} in '
                '${Convert.timeUntilTimestamp(info.airingAt)}'] = true;
          }

          if (media.edit.status != null) {
            final progress = media.edit.progress;
            if (info.nextEpisode != null && info.nextEpisode! - 1 > progress) {
              textRailItems['${info.nextEpisode! - 1 - progress}'
                  ' ep behind'] = true;
            }
          }
        }

        return SliverPersistentHeader(
          pinned: true,
          delegate: _Delegate(
            id: id,
            tabCtrl: tabCtrl,
            info: media?.info,
            coverUrl: coverUrl,
            topOffset: topOffset,
            textRailItems: textRailItems,
            imageWidth: MediaQuery.of(context).size.width < 430.0
                ? MediaQuery.of(context).size.width * 0.30
                : 100.0,
          ),
        );
      },
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
    required this.tabCtrl,
  });

  final int id;
  final MediaInfo? info;
  final double imageWidth;
  final String? coverUrl;
  final double topOffset;
  final Map<String, bool> textRailItems;
  final TabController tabCtrl;

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
            borderRadius: Consts.borderRadiusMin,
            child: Container(
              height: imageHeight,
              width: imageWidth,
              color: theme.colorScheme.surfaceVariant,
              child: cover != null
                  ? GestureDetector(
                      onTap: () => showPopUp(
                        context,
                        ImageDialog(info?.extraLargeCover ?? cover),
                      ),
                      child: CachedImage(cover),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 10),
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
                          color: theme.colorScheme.background,
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
        TopBarIcon(
          tooltip: 'Close',
          icon: Ionicons.chevron_back_outline,
          onTap: Navigator.of(context).pop,
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
          TopBarIcon(
            tooltip: 'More',
            icon: Ionicons.ellipsis_horizontal,
            onTap: () => showSheet(
              context,
              GradientSheet.link(context, info!.siteUrl!),
            ),
          ),
      ],
    );

    final body = SizedBox(
      height: height,
      child: Column(
        children: [
          Flexible(
            flex: (height - Consts.tapTargetSize).floor(),
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
                            onTap: () => showPopUp(
                              context,
                              ImageDialog(info!.banner!),
                            ),
                          )
                        : DecoratedBox(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant,
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
                      color: theme.colorScheme.background,
                      child: Container(
                        height: 0,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 15,
                              spreadRadius: 25,
                              color: theme.colorScheme.background,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    left: 10,
                    right: 10,
                    child: infoContent,
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: topOffset + Consts.tapTargetSize,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.colorScheme.background,
                            theme.colorScheme.background.withAlpha(200),
                            theme.colorScheme.background.withAlpha(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: topOffset + Consts.tapTargetSize,
                    child: Opacity(
                      opacity: transition,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.background,
                        ),
                      ),
                    ),
                  ),
                ],
                Positioned(
                  left: 0,
                  right: 0,
                  top: topOffset,
                  height: Consts.tapTargetSize,
                  child: topRow,
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: TabBar(
              splashBorderRadius: Consts.borderRadiusMin,
              controller: tabCtrl,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Related'),
                Tab(text: 'Characters'),
                Tab(text: 'Staff'),
                Tab(text: 'Reviews'),
                Tab(text: 'Recommendations'),
                Tab(text: 'Statistics'),
              ],
            ),
          ),
        ],
      ),
    );

    return transition < 1
        ? body
        : ClipRect(
            child: BackdropFilter(
              filter: Consts.blurFilter,
              child: DecoratedBox(
                decoration: BoxDecoration(color: theme.bottomAppBarTheme.color),
                child: body,
              ),
            ),
          );
  }

  static const _bannerBaseHeight = 200.0;

  double get imageHeight => imageWidth * Consts.coverHtoWRatio;

  @override
  double get minExtent => topOffset + Consts.tapTargetSize * 2;

  @override
  double get maxExtent =>
      topOffset + Consts.tapTargetSize + _bannerBaseHeight + imageHeight / 2;

  @override
  bool shouldRebuild(covariant _Delegate oldDelegate) =>
      info != oldDelegate.info;
}
