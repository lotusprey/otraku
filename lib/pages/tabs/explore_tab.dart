import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otraku/providers/explorable.dart';
import 'package:otraku/tools/blossom_loader.dart';
import 'package:otraku/tools/headers/explore_header.dart';
import 'package:otraku/tools/multichild_layouts/explore_grid.dart';
import 'package:otraku/tools/headers/headline_header.dart';
import 'package:provider/provider.dart';

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
        ExploreGrid(),
        _ConditionalLoader(),
      ],
    );
  }
}

class _ConditionalLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Provider.of<Explorable>(context).hasNextPage
              ? BlossomLoader()
              : null,
        ),
      ),
    );
  }
}
