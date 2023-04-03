import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/common/paged.dart';
import 'package:otraku/widgets/layouts/constrained_view.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';

/// Subscribes to a paginated, asynchronous provider.
/// Listens for errors and shows a pop up, if there is one.
/// [onRefresh] allows for refreshing. If [scrollCtrl] is
/// [PaginationController], pagination will automatically work.
/// [dateType] is a lowercase word for the data being handled (e.g. "reviews").
/// [onData] should return a sliver widget.
class PaginationView<T> extends StatelessWidget {
  const PaginationView({
    required this.provider,
    required this.scrollCtrl,
    required this.onRefresh,
    required this.dataType,
    required this.onData,
  });

  final ProviderListenable<AsyncValue<Paged<T>>> provider;
  final ScrollController scrollCtrl;
  final Future<void> Function() onRefresh;
  final String dataType;
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
                title: 'Failed to load $dataType',
                content: error.toString(),
              ),
            ),
          ),
        );

        var hasNext = false;
        final child =
            ref.watch<AsyncValue<Paged<T>>>(provider).unwrapPrevious().when(
                  loading: () => const SliverFillRemaining(
                    child: Center(child: Loader()),
                  ),
                  error: (_, __) => SliverFillRemaining(
                    child: Center(child: Text('Failed to load $dataType')),
                  ),
                  data: (data) {
                    hasNext = data.hasNext;

                    if (data.items.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(child: Text('No $dataType')),
                      );
                    }

                    return onData(data);
                  },
                );

        return ConstrainedView(
          child: CustomScrollView(
            physics: Consts.physics,
            controller: scrollCtrl,
            slivers: [
              SliverRefreshControl(onRefresh: onRefresh),
              child,
              SliverFooter(loading: hasNext),
            ],
          ),
        );
      },
    );
  }
}
