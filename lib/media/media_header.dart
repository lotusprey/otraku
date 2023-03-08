import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/discover/discover_models.dart';
import 'package:otraku/media/media_models.dart';
import 'package:otraku/media/media_providers.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/layouts/top_bar.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';
import 'package:otraku/widgets/overlays/toast.dart';
import 'package:otraku/widgets/text_rail.dart';

class MediaHeader extends StatelessWidget {
  const MediaHeader(this.id, this.coverUrl);

  final int id;
  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final data = ref.watch(mediaProvider(id).select((s) => s.valueOrNull));
        final textRailItems = <String, bool>{};

        if (data != null) {
          final info = data.info;

          if (info.isAdult) textRailItems['Adult'] = true;

          if (info.format != null) {
            textRailItems[Convert.clarifyEnum(info.format)!] = false;
          }

          if (data.edit.status != null) {
            textRailItems[Convert.adaptListStatus(
              data.edit.status!,
              info.type == DiscoverType.anime,
            )] = false;
          }

          if (info.airingAt != null) {
            textRailItems['Ep ${info.nextEpisode} in '
                '${Convert.timeUntilTimestamp(info.airingAt)}'] = true;
          }

          if (data.edit.status != null) {
            final progress = data.edit.progress;
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
            info: data?.info,
            coverUrl: coverUrl,
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

class _Delegate implements SliverPersistentHeaderDelegate {
  _Delegate({
    required this.id,
    required this.info,
    required this.imageWidth,
    required this.coverUrl,
    required this.textRailItems,
  });

  final int id;
  final MediaInfo? info;
  final double imageWidth;
  final String? coverUrl;
  final Map<String, bool> textRailItems;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final height = maxExtent;
    final extent = height - shrinkOffset;
    final opacity = shrinkOffset < (_bannerHeight - minExtent)
        ? shrinkOffset / (_bannerHeight - minExtent)
        : 1.0;

    final cover = info?.cover ?? coverUrl;
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            spreadRadius: 5,
            color: theme.colorScheme.background,
          ),
        ],
      ),
      child: FlexibleSpaceBar.createSettings(
        minExtent: minExtent,
        maxExtent: height,
        currentExtent: extent > minExtent ? extent : minExtent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              stretchModes: const [StretchMode.zoomBackground],
              background: Column(
                children: [
                  Expanded(
                    child: info?.banner != null
                        ? GestureDetector(
                            child: FadeImage(info!.banner!),
                            onTap: () => showPopUp(
                              context,
                              ImageDialog(info!.banner!),
                            ),
                          )
                        : const SizedBox(),
                  ),
                  SizedBox(height: height - _bannerHeight),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: height - _bannerHeight,
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
              bottom: 0,
              left: 10,
              right: 10,
              child: Row(
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
                                  ImageDialog(
                                    info?.extraLargeCover ?? cover,
                                  ),
                                ),
                                child: FadeImage(cover),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (info?.preferredTitle != null)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () =>
                                Toast.copy(context, info!.preferredTitle!),
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
                        if (textRailItems.isNotEmpty)
                          TextRail(
                            textRailItems,
                            style: theme.textTheme.labelMedium,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: minExtent,
              child: Opacity(
                opacity: opacity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.background,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        spreadRadius: 10,
                        color: theme.colorScheme.background,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: minExtent,
              child: Row(
                children: [
                  TopBarShadowIcon(
                    tooltip: 'Close',
                    icon: Ionicons.chevron_back_outline,
                    onTap: Navigator.of(context).pop,
                  ),
                  Expanded(
                    child: info?.preferredTitle == null
                        ? const SizedBox()
                        : Opacity(
                            opacity: opacity,
                            child: Text(
                              info!.preferredTitle!,
                              style: theme.textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                  ),
                  if (info?.siteUrl != null)
                    TopBarShadowIcon(
                      tooltip: 'More',
                      icon: Ionicons.ellipsis_horizontal,
                      onTap: () => showSheet(
                        context,
                        FixedGradientDragSheet.link(context, info!.siteUrl!),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _bannerHeight = 200.0;

  double get imageHeight => imageWidth * Consts.coverHtoWRatio;

  @override
  double get maxExtent => _bannerHeight + imageHeight / 2;

  @override
  double get minExtent => Consts.tapTargetSize;

  @override
  OverScrollHeaderStretchConfiguration? get stretchConfiguration =>
      OverScrollHeaderStretchConfiguration(stretchTriggerOffset: 100);

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;

  @override
  PersistentHeaderShowOnScreenConfiguration? get showOnScreenConfiguration =>
      null;

  @override
  FloatingHeaderSnapConfiguration? get snapConfiguration => null;

  @override
  TickerProvider? get vsync => null;
}
