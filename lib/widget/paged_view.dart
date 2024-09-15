import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/util/paged.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/widget/layout/constrained_view.dart';
import 'package:otraku/widget/loaders.dart';

/// A wrapper around [PagedSelectionView] to reduce boilerplate,
/// for the cases where [PagedSelectionView.select] is redundant.
class PagedView<T> extends StatelessWidget {
  const PagedView({
    required this.provider,
    required this.scrollCtrl,
    required this.onRefresh,
    required this.onData,
  });

  final ProviderListenable<AsyncValue<Paged<T>>> provider;
  final ScrollController scrollCtrl;
  final void Function(void Function(ProviderOrFamily) invalidate) onRefresh;
  final Widget Function(Paged<T>) onData;

  @override
  Widget build(BuildContext context) => PagedSelectionView(
        provider: provider,
        onRefresh: onRefresh,
        scrollCtrl: scrollCtrl,
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
  });

  final ProviderListenable<AsyncValue<T>> provider;
  final void Function(void Function(ProviderOrFamily) invalidate) onRefresh;

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
            error: (error, _) => SnackBarExtension.show(
              context,
              error.toString(),
            ),
          ),
        );

        return ref.watch(provider).unwrapPrevious().when(
              loading: () => const Center(child: Loader()),
              error: (err, __) => CustomScrollView(
                physics: Theming.bouncyPhysics,
                slivers: [
                  SliverRefreshControl(
                    onRefresh: () => onRefresh(ref.invalidate),
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
                    physics: Theming.bouncyPhysics,
                    controller: scrollCtrl,
                    slivers: [
                      SliverRefreshControl(
                        onRefresh: () => onRefresh(ref.invalidate),
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
