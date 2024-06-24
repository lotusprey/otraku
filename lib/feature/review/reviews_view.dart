import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/feature/review/review_models.dart';
import 'package:otraku/util/paged_controller.dart';
import 'package:otraku/feature/review/review_grid.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/layouts/floating_bar.dart';
import 'package:otraku/widget/layouts/scaffolds.dart';
import 'package:otraku/widget/layouts/top_bar.dart';
import 'package:otraku/widget/paged_view.dart';
import 'package:otraku/feature/review/reviews_filter_sheet.dart';
import 'package:otraku/feature/review/reviews_provider.dart';
import 'package:otraku/feature/review/reviews_filter_provider.dart';

class ReviewsView extends ConsumerStatefulWidget {
  const ReviewsView(this.id);

  final int id;

  @override
  ConsumerState<ReviewsView> createState() => _ReviewsViewState();
}

class _ReviewsViewState extends ConsumerState<ReviewsView> {
  late final _ctrl = PagedController(
    loadMore: () => ref.read(reviewsProvider(widget.id).notifier).fetch(),
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(
      reviewsProvider(widget.id).select((s) => s.valueOrNull?.total ?? 0),
    );

    return PageScaffold(
      child: TabScaffold(
        topBar: TopBar(
          title: 'Reviews',
          trailing: [
            if (count > 0)
              Padding(
                padding: const EdgeInsets.only(right: Theming.offset),
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
              icon: Ionicons.funnel_outline,
              tooltip: 'Filter',
              onTap: () => showReviewsFilterSheet(
                context: context,
                filter: ref.read(reviewsFilterProvider(widget.id)),
                onDone: (filter) => ref
                    .read(reviewsFilterProvider(widget.id).notifier)
                    .state = filter,
              ),
            ),
          ],
        ),
        child: PagedView<ReviewItem>(
          scrollCtrl: _ctrl,
          onRefresh: (invalidate) => invalidate(reviewsProvider(widget.id)),
          provider: reviewsProvider(widget.id),
          onData: (data) => ReviewGrid(data.items),
        ),
      ),
    );
  }
}
