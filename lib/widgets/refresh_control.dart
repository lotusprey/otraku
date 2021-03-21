import 'package:flutter/cupertino.dart';
import 'package:otraku/widgets/loader.dart';

class RefreshControl extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final bool Function() canRefresh;

  const RefreshControl({
    required this.onRefresh,
    required this.canRefresh,
  });

  @override
  Widget build(BuildContext context) => CupertinoSliverRefreshControl(
        onRefresh: () async {
          if (canRefresh()) await onRefresh();
        },
        builder: (
          _,
          refreshState,
          pulledExtent,
          refreshTriggerPullDistance,
          __,
        ) {
          double percentageComplete = pulledExtent / refreshTriggerPullDistance;
          if (percentageComplete > 1) percentageComplete = 1;

          switch (refreshState) {
            case RefreshIndicatorMode.armed:
            case RefreshIndicatorMode.refresh:
              return const Center(child: Loader());
            case RefreshIndicatorMode.drag:
            case RefreshIndicatorMode.done:
              const Curve opacity = Interval(0.0, 0.5, curve: Curves.easeInOut);
              return Opacity(
                opacity: opacity.transform(percentageComplete),
                child: const Center(child: Loader()),
              );
            case RefreshIndicatorMode.inactive:
              return const SizedBox();
          }
        },
      );
}
