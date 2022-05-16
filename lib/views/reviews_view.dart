import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/providers/reviews.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/widgets/grids/review_grid.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/loaders.dart/sliver_loaders.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class ReviewsView extends ConsumerStatefulWidget {
  ReviewsView(this.id);

  final int id;

  @override
  ConsumerState<ReviewsView> createState() => _ReviewsViewState();
}

class _ReviewsViewState extends ConsumerState<ReviewsView> {
  late final PaginationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = PaginationController(
      loadMore: () => ref.read(reviewsProvider(widget.id)).fetch(),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(
      reviewsProvider(widget.id).select((s) => s.reviewCount),
    );

    return PageLayout(
      topBar: TopBar(
        title: 'Reviews',
        items: [
          if (count > 0)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                count.toString(),
                style: Theme.of(context).textTheme.headline3,
              ),
            ),
        ],
      ),
      floatingBar: FloatingBar(
        scrollCtrl: _ctrl,
        child: ActionButton(
          tooltip: 'Sort',
          icon: Ionicons.funnel_outline,
          onTap: () {
            final notifier = ref.read(reviewSortProvider(widget.id).notifier);

            showSheet(
              context,
              DynamicGradientDragSheet(
                onTap: (i) => notifier.state = ReviewSort.values.elementAt(i),
                children: [
                  for (int i = 0; i < ReviewSort.values.length; i++)
                    Text(
                      ReviewSort.values.elementAt(i).text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: i != notifier.state.index
                          ? Theme.of(context).textTheme.headline1
                          : Theme.of(context).textTheme.headline1?.copyWith(
                              color: Theme.of(context).colorScheme.primary),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      builder: (_, __, ___) => Consumer(
        builder: (context, ref, _) {
          ref.listen<ReviewsNotifier>(
            reviewsProvider(widget.id),
            (_, s) => s.reviews.whenOrNull(
              error: (error, _) => showPopUp(
                context,
                ConfirmationDialog(
                  title: 'Could not load reviews',
                  content: error.toString(),
                ),
              ),
            ),
          );

          const empty = Center(child: Text('No Reviews'));

          return ref.watch(reviewsProvider(widget.id)).reviews.maybeWhen(
                loading: () => const Center(child: Loader()),
                orElse: () => empty,
                data: (data) {
                  if (data.items.isEmpty) return empty;

                  return CustomScrollView(
                    physics: Consts.physics,
                    controller: _ctrl,
                    slivers: [
                      SliverRefreshControl(
                        onRefresh: () {
                          ref.invalidate(reviewsProvider(widget.id));
                          return Future.value();
                        },
                        topOffset: PageOffset.of(context).top,
                      ),
                      ReviewGrid(items: data.items),
                      if (data.hasNext) const SliverFooterLoader(),
                    ],
                  );
                },
              );
        },
      ),
    );
  }
}
