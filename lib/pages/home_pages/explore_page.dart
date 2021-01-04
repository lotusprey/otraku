import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/controllers/explorer.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/tools/loader.dart';
import 'package:otraku/tools/navigators/control_header.dart';
import 'package:otraku/tools/layouts/result_grids.dart';
import 'package:otraku/tools/navigators/headline_header.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage();

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final _ctrl = ScrollController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      controller: _ctrl,
      slivers: [
        const HeadlineHeader('Explore', false),
        ExploreControlHeader(_ctrl),
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
    final explorable = Get.find<Explorer>();

    return Obx(() {
      if (explorable.isLoading)
        return const SliverFillRemaining(
          child: Center(child: Loader()),
        );

      final results = explorable.results;
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
