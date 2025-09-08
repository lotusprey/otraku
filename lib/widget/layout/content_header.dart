import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/build_context_extension.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/dialogs.dart';
import 'package:otraku/widget/sheets.dart';

class CustomContentHeader extends StatelessWidget {
  const CustomContentHeader({
    required this.title,
    required this.content,
    required this.siteUrl,
    this.bannerUrl,
    this.trailingTopButtons = const [],
    this.tabBarConfig,
  });

  final String? title;
  final PreferredSizeWidget content;
  final String? siteUrl;
  final String? bannerUrl;
  final List<Widget> trailingTopButtons;
  final TabBarConfig? tabBarConfig;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _Delegate(
        content: content,
        title: title,
        siteUrl: siteUrl,
        trailingTopButtons: trailingTopButtons,
        bannerUrl: bannerUrl,
        tabBarConfig: tabBarConfig,
        topPadding: MediaQuery.paddingOf(context).top,
      ),
    );
  }
}

class ContentHeader extends StatelessWidget {
  const ContentHeader({
    required this.imageUrl,
    required this.imageHeroTag,
    required this.imageHeightToWidthRatio,
    required this.title,
    required this.details,
    required this.siteUrl,
    this.imageLargeUrl,
    this.imageFit = BoxFit.cover,
    this.trailingTopButtons = const [],
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
        ((MediaQuery.sizeOf(context).width - Theming.offset * 3) / 2.0).clamp(0.0, 100.0);
    final imageHeight = imageWidth * imageHeightToWidthRatio;

    final content = _ImageContent(
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      imageHeroTag: imageHeroTag,
      imageUrl: imageUrl,
      imageLargeUrl: imageLargeUrl,
      imageFit: imageFit,
      title: title,
      details: details,
    );

    return SliverPersistentHeader(
      pinned: true,
      delegate: _Delegate(
        content: content,
        title: title,
        siteUrl: siteUrl,
        trailingTopButtons: trailingTopButtons,
        bannerUrl: bannerUrl,
        tabBarConfig: tabBarConfig,
        topPadding: MediaQuery.paddingOf(context).top,
      ),
    );
  }
}

typedef TabBarConfig = ({
  TabController tabCtrl,
  List<Tab> tabs,
  void Function() scrollToTop,
});

class _ImageContent extends StatelessWidget implements PreferredSizeWidget {
  const _ImageContent({
    required this.imageWidth,
    required this.imageHeight,
    required this.imageHeroTag,
    required this.imageUrl,
    required this.imageLargeUrl,
    required this.imageFit,
    required this.title,
    required this.details,
  });

  final double imageWidth;
  final double imageHeight;
  final Object imageHeroTag;
  final String? imageUrl;
  final String? imageLargeUrl;
  final BoxFit imageFit;
  final String? title;
  final Widget? details;

  @override
  Size get preferredSize => Size.fromHeight(imageHeight);

  @override
  Widget build(BuildContext context) {
    return Row(
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
                        style: TextTheme.of(context).titleLarge,
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
  }
}

class _Delegate extends SliverPersistentHeaderDelegate {
  const _Delegate({
    required this.content,
    required this.title,
    required this.siteUrl,
    required this.bannerUrl,
    required this.tabBarConfig,
    required this.trailingTopButtons,
    required this.topPadding,
  });

  final PreferredSizeWidget content;
  final double topPadding;
  final String? title;
  final List<Widget> trailingTopButtons;
  final String? siteUrl;
  final String? bannerUrl;
  final TabBarConfig? tabBarConfig;

  @override
  double get minExtent =>
      topPadding + Theming.normalTapTarget + (tabBarConfig != null ? Theming.minTapTarget : 0);

  @override
  double get maxExtent => minExtent + content.preferredSize.height + Theming.offset;

  @override
  bool shouldRebuild(covariant _Delegate oldDelegate) =>
      topPadding != oldDelegate.topPadding || title != oldDelegate.title;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
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

    final bannerBottomPadding = content.preferredSize.height / 2.0 + Theming.offset / 2;

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
