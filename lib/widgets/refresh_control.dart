import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';

class RefreshControl extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final bool Function() canRefresh;

  const RefreshControl({
    required this.onRefresh,
    required this.canRefresh,
  });

  @override
  Widget build(BuildContext context) => CupertinoSliverRefreshControl(
        refreshIndicatorExtent: 30,
        onRefresh: () async {
          if (canRefresh()) await onRefresh();
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
      );
}
