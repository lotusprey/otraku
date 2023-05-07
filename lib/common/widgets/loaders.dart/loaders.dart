import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/common/widgets/layouts/scaffolds.dart';
import 'package:otraku/common/widgets/loaders.dart/shimmer.dart';

class Loader extends StatelessWidget {
  const Loader();

  @override
  Widget build(BuildContext context) => Shimmer(ShimmerItem(
        Container(
          width: 60,
          height: 15,
          decoration: BoxDecoration(
            borderRadius: Consts.borderRadiusMin,
            color: Theme.of(context).colorScheme.surfaceVariant,
          ),
        ),
      ));
}

class SliverRefreshControl extends StatelessWidget {
  const SliverRefreshControl({required this.onRefresh});

  final void Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.only(top: scaffoldOffsets(context).top + 10),
      sliver: CupertinoSliverRefreshControl(
        refreshIndicatorExtent: 15,
        refreshTriggerPullDistance: 160,
        onRefresh: () {
          onRefresh();
          return Future.value();
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
}

class SliverFooter extends StatelessWidget {
  const SliverFooter({this.loading = false});

  final bool loading;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(
              top: 10,
              bottom: scaffoldOffsets(context).bottom + 10,
            ),
            child: loading ? const Loader() : null,
          ),
        ),
      );
}
