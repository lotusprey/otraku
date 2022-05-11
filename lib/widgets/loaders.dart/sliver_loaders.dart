import 'package:flutter/cupertino.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';

class SliverRefreshControl extends StatelessWidget {
  const SliverRefreshControl({
    required this.onRefresh,
    this.canRefresh,
    this.topOffset = 0,
  });

  final Future<void> Function() onRefresh;
  final bool Function()? canRefresh;
  final double topOffset;

  @override
  Widget build(BuildContext context) => SliverPadding(
        padding: EdgeInsets.only(top: topOffset),
        sliver: CupertinoSliverRefreshControl(
          refreshIndicatorExtent: 15,
          refreshTriggerPullDistance: 160,
          onRefresh: () async {
            if (canRefresh?.call() ?? true) await onRefresh();
          },
          builder: (
            _,
            refreshState,
            pulledExtent,
            refreshTriggerPullDistance,
            refreshIndicatorExtent,
          ) {
            double visibility = 0;
            if (pulledExtent > refreshIndicatorExtent) {
              pulledExtent -= refreshIndicatorExtent;
              refreshTriggerPullDistance -= refreshIndicatorExtent;
              visibility = pulledExtent / refreshTriggerPullDistance;
              if (visibility > 1) visibility = 1;
            }

            switch (refreshState) {
              case RefreshIndicatorMode.drag:
              case RefreshIndicatorMode.done:
              case RefreshIndicatorMode.armed:
              case RefreshIndicatorMode.refresh:
                return Opacity(
                  opacity: visibility,
                  child: const Center(child: Loader()),
                );
              case RefreshIndicatorMode.inactive:
                return const SizedBox();
            }
          },
        ),
      );
}

class SliverFooterLoader extends StatelessWidget {
  const SliverFooterLoader();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(
            top: 10,
            bottom: PageOffset.of(context).bottom + 10,
          ),
          child: const Loader(),
        ),
      ),
    );
  }
}
