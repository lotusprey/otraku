import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/common/widgets/cached_image.dart';
import 'package:otraku/common/widgets/layouts/top_bar.dart';
import 'package:otraku/common/widgets/overlays/dialogs.dart';
import 'package:otraku/common/widgets/overlays/sheets.dart';

class ReviewHeader extends StatelessWidget {
  const ReviewHeader({
    required this.id,
    required this.bannerUrl,
    required this.mediaTitle,
    required this.siteUrl,
  });

  final int id;
  final String? bannerUrl;
  final String? mediaTitle;
  final String? siteUrl;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _Delegate(
        id,
        bannerUrl,
        mediaTitle,
        siteUrl,
        MediaQuery.of(context).padding.top,
      ),
    );
  }
}

class _Delegate extends SliverPersistentHeaderDelegate {
  _Delegate(
    this.id,
    this.bannerUrl,
    this.title,
    this.siteUrl,
    this.topOffset,
  );

  final int id;
  final String? bannerUrl;
  final String? title;
  final String? siteUrl;
  final double topOffset;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    var transition = shrinkOffset / _bannerBaseHeight;
    if (transition > 1) transition = 1;

    final body = Stack(
      fit: StackFit.expand,
      children: [
        if (transition < 1) ...[
          Positioned.fill(
            child: bannerUrl != null
                ? GestureDetector(
                    child: Hero(tag: id, child: CachedImage(bannerUrl!)),
                    onTap: () => showPopUp(context, ImageDialog(bannerUrl!)),
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
            height: 15,
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
          child: Row(
            children: [
              TopBarIcon(
                tooltip: 'Close',
                icon: Ionicons.chevron_back_outline,
                onTap: Navigator.of(context).pop,
              ),
              Expanded(
                child: title != null
                    ? Opacity(
                        opacity: transition,
                        child: Text(
                          title!,
                          style: theme.textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    : const SizedBox(),
              ),
              if (siteUrl != null)
                TopBarIcon(
                  tooltip: 'More',
                  icon: Ionicons.ellipsis_horizontal,
                  onTap: () => showSheet(
                    context,
                    GradientSheet.link(context, siteUrl!),
                  ),
                ),
            ],
          ),
        ),
      ],
    );

    return transition < 1
        ? body
        : ClipRect(
            child: BackdropFilter(
              filter: Consts.blurFilter,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.navigationBarTheme.backgroundColor,
                ),
                child: body,
              ),
            ),
          );
  }

  static const _bannerBaseHeight = 80.0;

  @override
  double get minExtent => topOffset + Consts.tapTargetSize;

  @override
  double get maxExtent => topOffset + Consts.tapTargetSize + _bannerBaseHeight;

  @override
  bool shouldRebuild(covariant _Delegate oldDelegate) =>
      title != oldDelegate.title;
}
