import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/headers/explore_control_header.dart';
import 'package:otraku/tools/multichild_layouts/large_tile_grid.dart';
import 'package:otraku/models/large_tile_configuration.dart';
import 'package:otraku/tools/headers/headline_header.dart';
import 'package:provider/provider.dart';
import 'package:otraku/providers/explorable.dart';

class ExploreTab extends StatefulWidget {
  final ScrollController scrollCtrl;

  ExploreTab(this.scrollCtrl);

  @override
  _ExploreTabState createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  //Output settings
  LargeTileConfiguration _tileConfig;

  //Listens for the user reaching the bottom of the page
  void _onScroll() async {
    if (widget.scrollCtrl.position.pixels ==
            widget.scrollCtrl.position.maxScrollExtent &&
        !Provider.of<Explorable>(context, listen: false).isLoading) {
      Provider.of<Explorable>(context, listen: false).addPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      controller: widget.scrollCtrl,
      slivers: [
        const HeadlineHeader('Explore'),
        ExploreControlHeader(widget.scrollCtrl),
        LargeTileGrid(_tileConfig),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    widget.scrollCtrl.addListener(_onScroll);
    _tileConfig = ViewConfig.tileConfiguration;
  }

  @override
  void dispose() {
    widget.scrollCtrl.removeListener(_onScroll);
    super.dispose();
  }
}
