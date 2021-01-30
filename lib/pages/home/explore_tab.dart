import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/controllers/explorer.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/tools/layouts/review_grid.dart';
import 'package:otraku/tools/loader.dart';
import 'package:otraku/tools/navigation/control_header.dart';
import 'package:otraku/tools/layouts/result_grids.dart';
import 'package:otraku/tools/navigation/headline_header.dart';

class ExploreTab extends StatelessWidget {
  const ExploreTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      controller: Get.find<Explorer>().scrollCtrl,
      slivers: [
        const HeadlineHeader('Explore', false),
        ControlHeader(),
        _ExploreGrid(),
        _EndOfListLoader(),
        SliverToBoxAdapter(
          child: const SizedBox(height: 50),
        ),
      ],
    );
  }
}

class _ExploreGrid extends StatelessWidget {
  void _loadMore() {
    final explorable = Get.find<Explorer>();
    if (explorable.hasNextPage && !explorable.isLoading) {
      explorable.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final explorer = Get.find<Explorer>();

    return Obx(() {
      if (explorer.isLoading)
        return const SliverFillRemaining(
          child: Center(child: Loader()),
        );

      final results = explorer.results;
      if (results.isEmpty) {
        return NoResults();
      }

      if (results[0].browsable == Browsable.studio)
        return TitleList(results, _loadMore);

      if (results[0].browsable == Browsable.user)
        return TileGrid(
          results: results,
          loadMore: _loadMore,
          tile: Config.squareTile,
        );

      if (results[0].browsable == Browsable.review)
        return ReviewGrid(results, _loadMore);

      return TileGrid(
        results: results,
        loadMore: _loadMore,
        tile: Config.highTile,
      );
    });
  }
}

class _EndOfListLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Obx(
            () => Get.find<Explorer>().hasNextPage &&
                    !Get.find<Explorer>().isLoading
                ? Loader()
                : const SizedBox(),
          ),
        ),
      ),
    );
  }
}
