import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otraku/enums/anime_format_enum.dart';
import 'package:otraku/enums/enum_helper.dart';
import 'package:otraku/enums/manga_format_enum.dart';
import 'package:otraku/enums/media_status_enum.dart';
import 'package:otraku/providers/explorable_media.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/headers/custom_app_bar.dart';
import 'package:otraku/tools/multichild_layouts/filter_grid.dart';
import 'package:provider/provider.dart';

class FilterPage extends StatelessWidget {
  List<Widget> _gridSection({
    @required String name,
    @required FilterGrid grid,
    @required Palette palette,
  }) {
    if (grid == null) {
      return [];
    }

    final result = [
      Padding(
        padding: ViewConfig.PADDING,
        child: Text(name, style: palette.smallTitle),
      ),
      grid,
    ];

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<Theming>(context, listen: false).palette;
    final provider = Provider.of<ExplorableMedia>(context, listen: false);

    List<String> statusIn =
        provider.getFilterWithKey(ExplorableMedia.KEY_STATUS_IN);
    List<String> statusNotIn =
        provider.getFilterWithKey(ExplorableMedia.KEY_STATUS_NOT_IN);
    List<String> formatIn =
        provider.getFilterWithKey(ExplorableMedia.KEY_FORMAT_IN);
    List<String> formatNotIn =
        provider.getFilterWithKey(ExplorableMedia.KEY_FORMAT_NOT_IN);
    List<String> genreIn =
        provider.getFilterWithKey(ExplorableMedia.KEY_GENRE_IN);
    List<String> genreNotIn =
        provider.getFilterWithKey(ExplorableMedia.KEY_GENRE_NOT_IN);
    List<String> tagIn = provider.getFilterWithKey(ExplorableMedia.KEY_TAG_IN);
    List<String> tagNotIn =
        provider.getFilterWithKey(ExplorableMedia.KEY_TAG_NOT_IN);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: CustomAppBar(
        title: 'Filters',
        trailing: [
          IconButton(
            icon: Icon(
              Icons.done,
              size: Palette.ICON_MEDIUM,
              color: palette.accent,
            ),
            onPressed: () {
              provider.setGenreTagFilters(
                newStatusIn: statusIn,
                newStatusNotIn: statusNotIn,
                newFormatIn: formatIn,
                newFormatNotIn: formatNotIn,
                newGenreIn: genreIn,
                newGenreNotIn: genreNotIn,
                newTagIn: tagIn,
                newTagNotIn: tagNotIn,
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: <Widget>[
          ..._gridSection(
            name: 'Status',
            grid: FilterGrid(
              options: MediaStatus.values
                  .map((s) => clarifyEnum(describeEnum(s)))
                  .toList(),
              values: MediaStatus.values.map((s) => describeEnum(s)).toList(),
              optionIn: statusIn,
              optionNotIn: statusNotIn,
              rows: 1,
              whRatio: 0.2,
            ),
            palette: palette,
          ),
          ..._gridSection(
            name: 'Format',
            grid: FilterGrid(
              options: provider.type == 'ANIME'
                  ? AnimeFormatEnum.values
                      .map((f) => clarifyEnum(describeEnum(f)))
                      .toList()
                  : MangaFormatEnum.values
                      .map((f) => clarifyEnum(describeEnum(f)))
                      .toList(),
              values: provider.type == 'ANIME'
                  ? AnimeFormatEnum.values.map((f) => describeEnum(f)).toList()
                  : MangaFormatEnum.values.map((f) => describeEnum(f)).toList(),
              optionIn: formatIn,
              optionNotIn: formatNotIn,
              rows: 1,
              whRatio: 0.3,
            ),
            palette: palette,
          ),
          ..._gridSection(
            name: 'Genres',
            grid: FilterGrid(
              options: provider.genres,
              values: provider.genres,
              optionIn: genreIn,
              optionNotIn: genreNotIn,
              rows: 2,
              whRatio: 0.24,
            ),
            palette: palette,
          ),
          ..._gridSection(
            name: 'Tags',
            grid: FilterGrid(
              options: provider.tags.item1,
              values: provider.tags.item1,
              descriptions: provider.tags.item2,
              optionIn: tagIn,
              optionNotIn: tagNotIn,
              rows: 7,
              whRatio: 0.13,
            ),
            palette: palette,
          ),
        ],
      ),
    );
  }
}
