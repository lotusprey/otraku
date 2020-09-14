import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otraku/providers/explorable_media.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/tools/multichild_layouts/filter_grid.dart';
import 'package:provider/provider.dart';

class FilterPage extends StatefulWidget {
  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  static SizedBox _sizedBox = const SizedBox(height: 20);

  Palette _palette;
  List<String> _genreIn;
  List<String> _genreNotIn;
  List<String> _tagIn;
  List<String> _tagNotIn;

  @override
  void initState() {
    super.initState();
    _palette = Provider.of<Theming>(context, listen: false).palette;

    _genreIn = Provider.of<ExplorableMedia>(context, listen: false)
        .filterWithKey(ExplorableMedia.KEY_GENRE_IN);
    _genreNotIn = Provider.of<ExplorableMedia>(context, listen: false)
        .filterWithKey(ExplorableMedia.KEY_GENRE_NOT_IN);
    _tagIn = Provider.of<ExplorableMedia>(context, listen: false)
        .filterWithKey(ExplorableMedia.KEY_TAG_IN);
    _tagNotIn = Provider.of<ExplorableMedia>(context, listen: false)
        .filterWithKey(ExplorableMedia.KEY_TAG_NOT_IN);
  }

  List<Widget> _gridSection(String name, FilterGrid grid) {
    if (grid == null) {
      return [];
    }

    final result = [
      _sizedBox,
      Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Text(name, style: _palette.smallTitle),
      ),
      _sizedBox,
      grid,
    ];

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _palette.background,
      appBar: CupertinoNavigationBar(
        backgroundColor: _palette.background,
        actionsForegroundColor: _palette.accent,
        middle: Text('Filters', style: _palette.contrastedTitle),
        leading: IconButton(
          icon: Icon(
            Icons.close,
            size: Palette.ICON_MEDIUM,
            color: _palette.accent,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.done,
            size: Palette.ICON_MEDIUM,
            color: _palette.accent,
          ),
          onPressed: () {
            Provider.of<ExplorableMedia>(context, listen: false)
                .setGenreTagFilters(
              newGenreIn: _genreIn,
              newGenreNotIn: _genreNotIn,
              newTagIn: _tagIn,
              newTagNotIn: _tagNotIn,
            );
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: <Widget>[
          ..._gridSection(
            'Genres',
            FilterGrid(
              options:
                  Provider.of<ExplorableMedia>(context, listen: false).genres,
              optionIn: _genreIn,
              optionNotIn: _genreNotIn,
              rows: 2,
              whRatio: 0.4,
            ),
          ),
          ..._gridSection(
              'Tags',
              FilterGrid(
                options: Provider.of<ExplorableMedia>(context, listen: false)
                    .tags
                    .item1,
                descriptions:
                    Provider.of<ExplorableMedia>(context, listen: false)
                        .tags
                        .item2,
                optionIn: _tagIn,
                optionNotIn: _tagNotIn,
                rows: 7,
              )),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
