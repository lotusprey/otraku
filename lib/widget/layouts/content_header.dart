import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/build_context_extension.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/overlays/dialogs.dart';
import 'package:otraku/widget/overlays/sheets.dart';

class ContentHeader extends StatelessWidget {
  const ContentHeader({
    required this.imageUrl,
    required this.imageHeroTag,
    required this.imageHeightToWidthRatio,
    required this.title,
    required this.details,
    required this.siteUrl,
    this.imageFit = BoxFit.cover,
    this.trailingTopButtons = const [],
    this.imageLargeUrl,
    this.bannerUrl,
    this.tabBarConfig,
  });

  final String? imageUrl;
  final String? imageLargeUrl;
  final Object imageHeroTag;
  final double imageHeightToWidthRatio;
  final BoxFit imageFit;
  final String? title;
  final Widget? details;
  final List<Widget> trailingTopButtons;
  final String? siteUrl;
  final String? bannerUrl;
  final TabBarConfig? tabBarConfig;

  @override
  Widget build(BuildContext context) {
    final imageWidth =
        ((MediaQuery.sizeOf(context).width - Theming.offset * 3) / 2.0)
            .clamp(0.0, 100.0);

    return SliverPersistentHeader(
      pinned: true,
      delegate: _Delegate(
        topPadding: MediaQuery.paddingOf(context).top,
        imageUrl: imageUrl,
        imageLargeUrl: imageLargeUrl,
        imageHeroTag: imageHeroTag,
        imageWidth: imageWidth,
        imageHeight: imageHeightToWidthRatio * imageWidth,
        imageFit: imageFit,
        title: title,
        details: details,
        siteUrl: siteUrl,
        trailingTopButtons: trailingTopButtons,
        bannerUrl: bannerUrl,
        tabBarConfig: tabBarConfig,
      ),
    );
  }
}

typedef TabBarConfig = ({
  TabController tabCtrl,
  List<Tab> tabs,
  void Function() scrollToTop,
});

class _Delegate extends SliverPersistentHeaderDelegate {
  const _Delegate({
    required this.topPadding,
    required this.imageUrl,
    required this.imageHeroTag,
    required this.imageWidth,
    required this.imageHeight,
    required this.imageFit,
    required this.title,
    required this.details,
    required this.siteUrl,
    required this.trailingTopButtons,
    this.imageLargeUrl,
    this.bannerUrl,
    this.tabBarConfig,
  });

  final double topPadding;
  final String? imageUrl;
  final String? imageLargeUrl;
  final Object imageHeroTag;
  final double imageWidth;
  final double imageHeight;
  final BoxFit imageFit;
  final String? title;
  final Widget? details;
  final List<Widget> trailingTopButtons;
  final String? siteUrl;
  final String? bannerUrl;
  final TabBarConfig? tabBarConfig;

  @override
  double get minExtent =>
      topPadding +
      Theming.normalTapTarget +
      (tabBarConfig != null ? Theming.minTapTarget : 0);

  @override
  double get maxExtent => minExtent + imageHeight + Theming.offset;

  @override
  bool shouldRebuild(covariant _Delegate oldDelegate) =>
      topPadding != oldDelegate.topPadding || title != oldDelegate.title;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);

    final minHeight = minExtent;
    final maxHeight = maxExtent;
    final transition = (shrinkOffset / (maxHeight - minHeight)).clamp(0.0, 1.0);

    final topButtons = Row(
      children: [
        if (GoRouter.of(context).canPop())
          IconButton(
            tooltip: 'Close',
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: context.back,
          )
        else
          const SizedBox(width: Theming.offset),
        if (title == null)
          const Spacer()
        else
          Expanded(
            child: Opacity(
              opacity: transition,
              child: Text(
                title!,
                style: theme.textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ...trailingTopButtons,
        IconButton(
          tooltip: 'More',
          icon: const Icon(Ionicons.ellipsis_horizontal),
          onPressed: siteUrl != null
              ? () => showSheet(
                    context,
                    SimpleSheet.link(context, siteUrl!),
                  )
              : null,
        ),
      ],
    );

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Hero(
          tag: imageHeroTag,
          child: ClipRRect(
            borderRadius: Theming.borderRadiusSmall,
            child: SizedBox(
              height: imageHeight,
              width: imageWidth,
              child: imageUrl != null
                  ? GestureDetector(
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => ImageDialog(
                          imageLargeUrl ?? imageUrl!,
                        ),
                      ),
                      child: CachedImage(imageUrl!, fit: imageFit),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(width: Theming.offset),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (title != null)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => SnackBarExtension.copy(context, title!),
                      child: Text(
                        title!,
                        overflow: TextOverflow.fade,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                  if (details != null) ...[
                    const SizedBox(height: 5),
                    details!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );

    final bannerBottomPadding = imageHeight / 2.0 + Theming.offset / 2;

    Widget body = Stack(
      fit: StackFit.expand,
      children: [
        if (transition < 1) ...[
          if (bannerUrl != null) ...[
            Positioned.fill(
              bottom: bannerBottomPadding,
              child: CachedImage(bannerUrl!),
            ),
            Positioned.fill(
              bottom: bannerBottomPadding,
              child: GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => ImageDialog(bannerUrl!),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.center,
                      tileMode: TileMode.mirror,
                      colors: [
                        theme.colorScheme.surface,
                        theme.colorScheme.surface.withAlpha(150),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          Positioned(
            left: Theming.offset,
            right: Theming.offset,
            bottom: Theming.offset / 2,
            top: Theming.offset / 2 + topPadding + Theming.normalTapTarget,
            child: content,
          ),
          if (transition > 0.1)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withAlpha(
                    (transition * 255).floor(),
                  ),
                ),
              ),
            ),
        ],
        Positioned(
          left: 0,
          right: 0,
          top: topPadding,
          height: Theming.normalTapTarget,
          child: topButtons,
        ),
      ],
    );

    if (tabBarConfig != null) {
      body = Column(
        children: [
          Flexible(child: body),
          Material(
            color: Colors.transparent,
            child: TabBar(
              tabAlignment: TabAlignment.center,
              splashBorderRadius: Theming.borderRadiusSmall,
              controller: tabBarConfig!.tabCtrl,
              isScrollable: true,
              tabs: tabBarConfig!.tabs,
              onTap: (index) {
                if (index == tabBarConfig!.tabCtrl.index) {
                  tabBarConfig!.scrollToTop();
                }
              },
            ),
          ),
        ],
      );
    }

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
}
