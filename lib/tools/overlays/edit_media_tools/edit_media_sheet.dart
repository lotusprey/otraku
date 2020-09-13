import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otraku/models/entry_user_data.dart';
import 'package:otraku/models/media_page_data.dart';
import 'package:otraku/providers/media_item.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/overlays/edit_media_tools/grid_child.dart';
import 'package:otraku/tools/overlays/edit_media_tools/number_field.dart';
import 'package:otraku/tools/overlays/edit_media_tools/save_button.dart';
import 'package:provider/provider.dart';

import 'drop_down_implementation.dart';

class EditMediaSheet extends StatefulWidget {
  final MediaPageData media;
  final Function(EntryUserData) update;

  EditMediaSheet(this.media, this.update);

  @override
  _EditMediaSheetState createState() => _EditMediaSheetState();
}

class _EditMediaSheetState extends State<EditMediaSheet> {
  EntryUserData _oldData;
  EntryUserData _newData;
  Palette _palette;
  double _topInset;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: _topInset),
      padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(5),
          topRight: Radius.circular(5),
        ),
        color: _palette.background,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                iconSize: Palette.ICON_MEDIUM,
                color: _palette.contrast,
                onPressed: () => Navigator.of(context).pop(),
              ),
              if (_oldData != null)
                SaveButton(
                  isAnime: widget.media.type == 'ANIME',
                  oldData: _oldData,
                  newData: _newData,
                  update: widget.update,
                  palette: _palette,
                ),
            ],
          ),
          if (_oldData != null)
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverGrid.extent(
                    maxCrossAxisExtent: 200,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2,
                    children: [
                      GridChild(
                        title: 'Status',
                        body: DropDownImplementation(
                          _newData,
                          widget.media.type == 'ANIME',
                          _palette,
                        ),
                        palette: _palette,
                      ),
                      GridChild(
                        title: 'Progress',
                        body: SizedBox(
                          height: 40,
                          child: NumberField(
                            palette: _palette,
                            initialValue: _newData.progress,
                            maxValue: _newData.progressMax,
                          ),
                        ),
                        palette: _palette,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _topInset = Provider.of<ViewConfig>(context, listen: false).topInset + 20;

    Provider.of<MediaItem>(context, listen: false)
        .fetchUserData(widget.media.id)
        .then((data) {
      if (mounted) {
        setState(() {
          _oldData = data;
          _newData = EntryUserData.from(_oldData);
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _palette = Provider.of<Theming>(context).palette;
  }
}
