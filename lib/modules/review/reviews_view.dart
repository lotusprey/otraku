import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/modules/review/review_models.dart';
import 'package:otraku/common/utils/paged_controller.dart';
import 'package:otraku/modules/review/review_grid.dart';
import 'package:otraku/common/widgets/layouts/floating_bar.dart';
import 'package:otraku/common/widgets/layouts/scaffolds.dart';
import 'package:otraku/common/widgets/layouts/top_bar.dart';
import 'package:otraku/common/widgets/paged_view.dart';
import 'package:otraku/modules/review/reviews_filter_sheet.dart';
import 'package:otraku/modules/review/reviews_provider.dart';
import 'package:otraku/modules/review/reviews_filter_provider.dart';

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
