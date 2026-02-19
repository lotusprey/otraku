import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:otraku/util/paged.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/widget/layout/constrained_view.dart';
import 'package:otraku/widget/loaders.dart';

class PagedView<T> extends StatelessWidget {
  const PagedView({
    required this.provider,
    required this.scrollCtrl,
    required this.onRefresh,
    required this.onData,
    this.padded = true,
    this.header,
  });

  final ProviderListenable<AsyncValue<Paged<T>>> provider;

  /// If [scrollCtrl] is [PagedController], pagination will automatically work.
  final ScrollController scrollCtrl;

  /// The [invalidate] parameter is the method of [PagedView]'s [ref].
  /// The parameter is useful, because the parent widget
  /// may not have a [WidgetRef] at its disposal.
  final void Function(void Function(ProviderOrFamily) invalidate) onRefresh;

  /// [onData] should return a sliver widget, displaying the items.
  final Widget Function(Paged<T>) onData;

  /// If [padded] is true, the result of [onData] will be padded.
  final bool padded;

  final Widget? header;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        ref.listen<AsyncValue>(
          provider,
          (_, s) =>
              s.whenOrNull(error: (error, _) => SnackBarExtension.show(context, error.toString())),
        );

        return ref
            .watch(provider)
            .unwrapPrevious()
            .when(
              loading: () => const Center(child: Loader()),
              error: (_, _) => CustomScrollView(
                physics: Theming.bouncyPhysics,
                slivers: [
                  SliverRefreshControl(onRefresh: () => onRefresh(ref.invalidate)),
                  ?header,
                  const SliverFillRemaining(child: Center(child: Text('Failed to load'))),
                ],
              ),
              data: (data) {
                return ConstrainedView(
                  padded: padded,
                  child: CustomScrollView(
                    physics: Theming.bouncyPhysics,
                    controller: scrollCtrl,
                    slivers: [
                      SliverRefreshControl(onRefresh: () => onRefresh(ref.invalidate)),
                      ?header,
                      data.items.isEmpty
                          ? const SliverFillRemaining(child: Center(child: Text('No results')))
                          : onData(data),
                      SliverFooter(loading: data.hasNext),
                    ],
                  ),
                );
              },
            );
      },
    );
  }
}
