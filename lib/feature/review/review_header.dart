import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/util/extensions.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/layouts/top_bar.dart';
import 'package:otraku/widget/overlays/dialogs.dart';
import 'package:otraku/widget/overlays/sheets.dart';

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
        MediaQuery.paddingOf(context).top,
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
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => ImageDialog(bannerUrl!),
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
            height: 15,
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
                decoration: BoxDecoration(color: theme.colorScheme.surface),
              ),
            ),
          ),
        ],
        Positioned(
          left: 0,
          right: 0,
          top: topOffset,
          height: Theming.minTapTarget,
          child: Row(
            children: [
              TopBarIcon(
                tooltip: 'Close',
                icon: Ionicons.chevron_back_outline,
                onTap: context.back,
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
                    SimpleSheet.link(context, siteUrl!),
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
              filter: Theming.blurFilter,
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
  double get minExtent => topOffset + Theming.minTapTarget;

  @override
  double get maxExtent => topOffset + Theming.minTapTarget + _bannerBaseHeight;

  @override
  bool shouldRebuild(covariant _Delegate oldDelegate) =>
      title != oldDelegate.title;
}
