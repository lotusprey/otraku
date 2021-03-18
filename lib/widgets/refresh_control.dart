import 'package:flutter/cupertino.dart';
import 'package:otraku/widgets/loader.dart';

class RefreshControl extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final bool Function()? canRefresh;
  const RefreshControl({
    required this.onRefresh,
    this.canRefresh,
  });

  @override
  Widget build(BuildContext context) => CupertinoSliverRefreshControl(
        refreshTriggerPullDistance: 150,
        onRefresh: () async {
          if (canRefresh == null || canRefresh!()) await onRefresh();
        },
        builder: (_, __, ___, ____, _____) => const Center(child: Loader()),
      );
}
