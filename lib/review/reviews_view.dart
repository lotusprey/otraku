import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/review/review_models.dart';
import 'package:otraku/review/review_providers.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/review/review_grid.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/layouts/top_bar.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class ReviewsView extends ConsumerStatefulWidget {
  const ReviewsView(this.id);

  final int id;

  @override
  ConsumerState<ReviewsView> createState() => _ReviewsViewState();
}

class _ReviewsViewState extends ConsumerState<ReviewsView> {
  late final _ctrl = PaginationController(
    loadMore: () => ref.read(reviewsProvider(widget.id)).fetch(),
  );

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
        trailing: [
          if (count > 0)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                count.toString(),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
        ],
      ),
      floatingBar: FloatingBar(
        scrollCtrl: _ctrl,
        children: [
          ActionButton(
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
                            ? Theme.of(context).textTheme.titleLarge
                            : Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      child: Consumer(
        child: SliverRefreshControl(
          onRefresh: () => ref.invalidate(reviewsProvider(widget.id)),
        ),
        builder: (context, ref, refreshControl) {
          ref.listen<ReviewsNotifier>(
            reviewsProvider(widget.id),
            (_, s) => s.reviews.whenOrNull(
              error: (error, _) => showPopUp(
                context,
                ConfirmationDialog(
                  title: 'Failed to load reviews',
                  content: error.toString(),
                ),
              ),
            ),
          );

          return ref.watch(reviewsProvider(widget.id)).reviews.when(
                loading: () => const Center(child: Loader()),
                error: (_, __) =>
                    const Center(child: Text('Failed to load reviews')),
                data: (data) {
                  if (data.items.isEmpty) {
                    return const Center(child: Text('No Reviews'));
                  }

                  return Center(
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxWidth: Consts.layoutBig),
                      child: CustomScrollView(
                        physics: Consts.physics,
                        controller: _ctrl,
                        slivers: [
                          refreshControl!,
                          ReviewGrid(data.items),
                          SliverFooter(loading: data.hasNext),
                        ],
                      ),
                    ),
                  );
                },
              );
        },
      ),
    );
  }
}
