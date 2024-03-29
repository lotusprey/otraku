import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/common/models/paged.dart';
import 'package:otraku/common/widgets/layouts/constrained_view.dart';
import 'package:otraku/common/widgets/loaders/loaders.dart';
import 'package:otraku/common/widgets/overlays/dialogs.dart';

/// A wrapper around [PagedSelectionView] to reduce boilerplate,
/// for the cases where [PagedSelectionView.select] is redundant.
class PagedView<T> extends StatelessWidget {
  const PagedView({
    required this.provider,
    required this.scrollCtrl,
    required this.onRefresh,
    required this.onData,
    this.withTopOffset = true,
  });

  final ProviderListenable<AsyncValue<Paged<T>>> provider;
  final ScrollController scrollCtrl;
  final void Function() onRefresh;
  final Widget Function(Paged<T>) onData;
  final bool withTopOffset;

  @override
  Widget build(BuildContext context) => PagedSelectionView(
        provider: provider,
        onRefresh: onRefresh,
        scrollCtrl: scrollCtrl,
        withTopOffset: withTopOffset,
        onData: onData,
        select: (data) => data,
      );
}

class PagedSelectionView<T, U> extends StatelessWidget {
  const PagedSelectionView({
    required this.provider,
    required this.scrollCtrl,
    required this.onRefresh,
    required this.onData,
    required this.select,
    this.withTopOffset = true,
  });

  final ProviderListenable<AsyncValue<T>> provider;
  final void Function() onRefresh;
  final bool withTopOffset;

  /// When data is available, [select] extracts a paginated list.
  final Paged<U> Function(T) select;

  /// [onData] should return a sliver widget!
  final Widget Function(Paged<U>) onData;

  /// If [scrollCtrl] is [PagedController], pagination will automatically work.
  final ScrollController scrollCtrl;

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
              error: (err, __) => CustomScrollView(
                physics: Consts.physics,
                slivers: [
                  SliverRefreshControl(
                    withTopOffset: withTopOffset,
                    onRefresh: onRefresh,
                  ),
                  const SliverFillRemaining(
                    child: Center(child: Text('Failed to load')),
                  ),
                ],
              ),
              data: (data) {
                final selection = select(data);
                return ConstrainedView(
                  child: CustomScrollView(
                    physics: Consts.physics,
                    controller: scrollCtrl,
                    slivers: [
                      SliverRefreshControl(
                        withTopOffset: withTopOffset,
                        onRefresh: onRefresh,
                      ),
                      selection.items.isEmpty
                          ? const SliverFillRemaining(
                              child: Center(child: Text('No results')),
                            )
                          : onData(selection),
                      SliverFooter(loading: selection.hasNext),
                    ],
                  ),
                );
              },
            );
      },
    );
  }
}
