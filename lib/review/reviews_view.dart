import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/review/review_models.dart';
import 'package:otraku/review/review_providers.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/review/review_grid.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/scaffolds.dart';
import 'package:otraku/widgets/layouts/top_bar.dart';
import 'package:otraku/widgets/overlays/sheets.dart';
import 'package:otraku/widgets/pagination_view.dart';

class ReviewsView extends ConsumerStatefulWidget {
  const ReviewsView(this.id);

  final int id;

  @override
  ConsumerState<ReviewsView> createState() => _ReviewsViewState();
}

class _ReviewsViewState extends ConsumerState<ReviewsView> {
  late final _ctrl = PaginationController(
    loadMore: () => ref.read(reviewsProvider(widget.id).notifier).fetch(),
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The [reviewCount] is not part of the state of [ReviewsNotifier] and
    // changes cannot be tracket through selecting it. it would be good to
    // make it part of the state later.
    ref.watch(reviewsProvider(widget.id));
    final count = ref.watch(reviewsProvider(widget.id).notifier).reviewCount;

    return PageScaffold(
      child: TabScaffold(
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
                final theme = Theme.of(context);
                final notifier =
                    ref.read(reviewSortProvider(widget.id).notifier);

                showSheet(
                  context,
                  DynamicGradientDragSheet(
                    onTap: (i) =>
                        notifier.state = ReviewSort.values.elementAt(i),
                    children: [
                      for (int i = 0; i < ReviewSort.values.length; i++)
                        Text(
                          ReviewSort.values.elementAt(i).text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: i != notifier.state.index
                              ? theme.textTheme.titleLarge
                              : theme.textTheme.titleLarge
                                  ?.copyWith(color: theme.colorScheme.primary),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        child: Consumer(
          builder: (context, ref, refreshControl) {
            return PaginationView<ReviewItem>(
              provider: reviewsProvider(widget.id),
              scrollCtrl: _ctrl,
              dataType: 'reviews',
              onRefresh: () {
                ref.invalidate(reviewsProvider(widget.id));
                return Future.value();
              },
              onData: (data) => ReviewGrid(data.items),
            );
          },
        ),
      ),
    );
  }
}
