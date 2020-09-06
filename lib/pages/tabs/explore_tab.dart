import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otraku/pages/pushable/filter_page.dart';
import 'package:otraku/pages/pushable/search_page.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/multichild_layouts/large_tile_grid.dart';
import 'package:otraku/models/large_tile_configuration.dart';
import 'package:otraku/tools/headers/media_control_header.dart';
import 'package:otraku/tools/headers/headline_header.dart';
import 'package:otraku/tools/overlays/explore_sort_sheet.dart';
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
    final provider = Provider.of<ExplorableMedia>(context, listen: false);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      controller: widget.scrollCtrl,
      slivers: <Widget>[
        HeadlineHeader(),
        SliverPersistentHeader(
          pinned: false,
          floating: true,
          delegate: MediaControlHeader(
            context: context,
            updateSegmentedControl: (value) => provider.type = value as String,
            segmentedControlPairs: {
              'Anime': 'ANIME',
              'Manga': 'MANGA',
            },
            searchActivate: () => Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (ctx) => SearchPage(
                  searchFn: (String value) => provider.search = value,
                  text: provider.search,
                ),
              ),
            ),
            searchDeactivate: () => provider.search = null,
            isSearchActive: provider.search != null,
            filterActivate: () => Navigator.of(context).push(
              CupertinoPageRoute(builder: (ctx) => FilterPage()),
            ),
            filterDeactivate: () => provider.setGenreTagFilters(
              newGenreIn: null,
              newGenreNotIn: null,
              newTagIn: null,
              newTagNotIn: null,
            ),
            isFilterActive: provider.genreIn.length > 0 ||
                provider.genreNotIn.length > 0 ||
                provider.tagIn.length > 0 ||
                provider.tagNotIn.length > 0,
            refresh: () => provider.fetchMedia(clean: true),
            sort: () => showModalBottomSheet(
              context: context,
              builder: (ctx) => ExploreSortSheet(),
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
            ),
          ),
        ),
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
