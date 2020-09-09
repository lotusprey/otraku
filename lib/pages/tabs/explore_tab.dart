import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/headers/explore_control_header.dart';
import 'package:otraku/tools/multichild_layouts/large_tile_grid.dart';
import 'package:otraku/models/large_tile_configuration.dart';
import 'package:otraku/tools/headers/headline_header.dart';
import 'package:provider/provider.dart';
import 'package:otraku/providers/explorable_media.dart';

class ExploreTab extends StatefulWidget {
  final ScrollController scrollCtrl;

  ExploreTab(this.scrollCtrl);

  @override
  _ExploreTabState createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  //Output settings
  Palette _palette;
  LargeTileConfiguration _tileConfig;
  bool _didChangeDependencies = false;

  //Listens for the user reaching the bottom of the page
  void _onScroll() async {
    if (widget.scrollCtrl.position.pixels ==
            widget.scrollCtrl.position.maxScrollExtent &&
        !Provider.of<ExplorableMedia>(context, listen: false).isLoading) {
      Provider.of<ExplorableMedia>(context, listen: false).addPage();
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
        const ExploreControlHeader(),
        LargeTileGrid(_palette, _tileConfig),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _palette = Provider.of<Theming>(context).palette;

    if (!_didChangeDependencies) {
      widget.scrollCtrl.addListener(_onScroll);

      _tileConfig = Provider.of<ViewConfig>(
        context,
        listen: false,
      ).tileConfiguration;

      _didChangeDependencies = true;
    }
  }

  @override
  void dispose() {
    widget.scrollCtrl.removeListener(_onScroll);
    super.dispose();
  }
}
