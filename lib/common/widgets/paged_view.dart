import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/common/models/paged.dart';
import 'package:otraku/common/widgets/layouts/constrained_view.dart';
import 'package:otraku/common/widgets/loaders.dart/loaders.dart';
import 'package:otraku/common/widgets/overlays/dialogs.dart';

/// Subscribes to a paginated, asynchronous provider.
/// Shows a pop up, if there is an error.
/// [onData] should return a sliver widget!
/// If [scrollCtrl] is [PagedController], pagination will automatically work.
class PagedView<T> extends StatelessWidget {
  const PagedView({
    required this.provider,
    required this.scrollCtrl,
    required this.onRefresh,
    required this.onData,
  });

  final ProviderListenable<AsyncValue<Paged<T>>> provider;
  final ScrollController scrollCtrl;
  final void Function() onRefresh;
  final Widget Function(Paged<T>) onData;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        ref.listen<AsyncValue>(
          provider,
          (_, s) => s.whenOrNull(
            error: (error, _) => showPopUp(
              context,
              ConfirmationDialog(
                title: 'Failed to load',
                content: error.toString(),
              ),
            ),
          ),
        );

        return ref.watch(provider).unwrapPrevious().when(
              loading: () => const Center(child: Loader()),
              error: (_, __) => CustomScrollView(
                physics: Consts.physics,
                slivers: [
                  SliverRefreshControl(onRefresh: onRefresh),
                  const SliverFillRemaining(
                    child: Center(child: Text('Failed to load')),
                  ),
                ],
              ),
              data: (data) => ConstrainedView(
                child: CustomScrollView(
                  physics: Consts.physics,
                  controller: scrollCtrl,
                  slivers: [
                    SliverRefreshControl(onRefresh: onRefresh),
                    data.items.isEmpty
                        ? const SliverFillRemaining(
                            child: Center(child: Text('No results')),
                          )
                        : onData(data),
                    SliverFooter(loading: data.hasNext),
                  ],
                ),
              ),
            );
      },
    );
  }
}
