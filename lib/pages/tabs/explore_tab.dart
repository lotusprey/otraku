import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/explorable.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/tools/loader.dart';
import 'package:otraku/tools/navigators/control_header.dart';
import 'package:otraku/tools/layouts/result_grids.dart';
import 'package:otraku/tools/navigators/headline_header.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab();

  @override
  _ExploreTabState createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
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
        ControlHeader(false, _ctrl),
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
    final explorable = Get.find<Explorable>();
    if (explorable.hasNextPage && !explorable.isLoading) {
      explorable.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final explorable = Get.find<Explorable>();

    return Obx(() {
      if (explorable.isLoading)
        return const SliverFillRemaining(
          child: Center(child: Loader()),
        );

      final results = explorable.results;
      if (results.length == 0) {
        return NoResults();
      }

      if (results[0].browsable == Browsable.studio)
        return TitleList(results, _loadMore);

      return LargeGrid(results, _loadMore);
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
            () => Get.find<Explorable>().hasNextPage &&
                    !Get.find<Explorable>().isLoading
                ? Loader()
                : const SizedBox(),
          ),
        ),
      ),
    );
  }
}
