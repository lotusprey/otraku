import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/explorable.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/tools/blossom_loader.dart';
import 'package:otraku/tools/headers/explore_header.dart';
import 'package:otraku/tools/layouts/result_grid.dart';
import 'package:otraku/tools/headers/headline_header.dart';

class ExploreTab extends StatefulWidget {
  final ScrollController scrollCtrl;

  ExploreTab(this.scrollCtrl);

  @override
  _ExploreTabState createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      controller: widget.scrollCtrl,
      slivers: [
        const HeadlineHeader('Explore', false),
        ExploreHeader(widget.scrollCtrl),
        _ExploreGrid(),
        _ConditionalLoader(),
      ],
    );
  }
}

class _ExploreGrid extends StatelessWidget {
  void _loadMore() {
    final explorable = Get.find<Explorable>();
    if (explorable.hasNextPage && !explorable.isLoading) {
      explorable.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) => Obx(() {
        final results = Get.find<Explorable>().results;

        if (results.length == 0) {
          return NoResults();
        }

        if (results[0].browsable == Browsable.studios) {
          return TitleList(results, _loadMore);
        }

        return LargeGrid(results, _loadMore);
      });
}

class _ConditionalLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Obx(
            () => Get.find<Explorable>().hasNextPage
                ? BlossomLoader()
                : const SizedBox(),
          ),
        ),
      ),
    );
  }
}
