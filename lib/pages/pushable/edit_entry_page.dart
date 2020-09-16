import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otraku/enums/media_list_status_enum.dart';
import 'package:otraku/models/entry_user_data.dart';
import 'package:otraku/providers/anime_collection.dart';
import 'package:otraku/providers/collection_provider.dart';
import 'package:otraku/providers/manga_collection.dart';
import 'package:otraku/providers/media_item.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/blossom_loader.dart';
import 'package:otraku/tools/headers/custom_app_bar.dart';
import 'package:otraku/tools/overlays/edit_media_tools/drop_down_implementation.dart';
import 'package:otraku/tools/overlays/edit_media_tools/grid_child.dart';
import 'package:otraku/tools/overlays/edit_media_tools/number_field.dart';
import 'package:provider/provider.dart';

class EditEntryPage extends StatefulWidget {
  final int mediaId;
  final Function(MediaListStatus) update;

  EditEntryPage(this.mediaId, this.update);

  @override
  _EditEntryPageState createState() => _EditEntryPageState();
}

class _EditEntryPageState extends State<EditEntryPage> {
  CollectionProvider _collection;
  EntryUserData _oldData;
  EntryUserData _newData;
  Palette _palette;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _palette.background,
      appBar: _EditAppBar(
        oldData: _oldData,
        newData: _newData,
        collection: _collection,
        update: widget.update,
        palette: _palette,
      ),
      body: _oldData != null
          ? Padding(
              padding: ViewConfig.PADDING,
              child: GridView(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2,
                ),
                children: [
                  GridChild(
                    title: 'Status',
                    body: DropDownImplementation(_newData, _palette),
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
            )
          : const SizedBox(),
    );
  }

  @override
  void initState() {
    super.initState();
    Provider.of<MediaItem>(context, listen: false)
        .fetchUserData(widget.mediaId)
        .then((data) {
      if (mounted) {
        setState(() {
          _oldData = data;
          _newData = EntryUserData.from(_oldData);
          _collection = _newData.type == 'ANIME'
              ? Provider.of<AnimeCollection>(context, listen: false)
              : Provider.of<MangaCollection>(context, listen: false);
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

class _EditAppBar extends StatefulWidget implements PreferredSizeWidget {
  final EntryUserData oldData;
  final EntryUserData newData;
  final CollectionProvider collection;
  final Function(MediaListStatus) update;
  final Palette palette;

  _EditAppBar({
    @required this.oldData,
    @required this.newData,
    @required this.collection,
    @required this.update,
    @required this.palette,
  });

  @override
  __EditAppBarState createState() => __EditAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(CustomAppBar.CUSTOM_APP_BAR_HEIGHT);
}

class __EditAppBarState extends State<_EditAppBar> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: 'Edit',
      trailing: widget.oldData != null && !_isLoading
          ? [
              IconButton(
                icon: const Icon(Icons.delete),
                color: widget.palette.contrast,
                iconSize: Palette.ICON_MEDIUM,
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: widget.palette.primary,
                    title: Text(
                      'Remove entry?',
                      style: widget.palette.smallTitle,
                    ),
                    actions: [
                      FlatButton(
                        child: Text('No', style: widget.palette.paragraph),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      FlatButton(
                        child: Text('Yes', style: widget.palette.exclamation),
                        onPressed: () {
                          setState(() => _isLoading = true);
                          widget.collection
                              .removeEntry(widget.oldData)
                              .then((ok) {
                            Navigator.of(context).pop();
                            if (ok) {
                              widget.update(null);
                              Navigator.of(context).pop();
                            } else {
                              setState(() => _isLoading = false);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.save),
                color: widget.palette.contrast,
                iconSize: Palette.ICON_MEDIUM,
                onPressed: () {
                  setState(() => _isLoading = true);
                  widget.collection
                      .updateEntry(widget.oldData, widget.newData)
                      .then((ok) {
                    if (ok) widget.update(widget.newData.status);
                    Navigator.of(context).pop();
                  });
                },
              ),
            ]
          : const [BlossomLoader(size: 30)],
    );
  }
}
