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
import 'package:otraku/tools/overlays/edit_media_tools/number_field.dart';
import 'package:otraku/tools/overlays/edit_media_tools/score_field.dart';
import 'package:provider/provider.dart';

class EditEntryPage extends StatefulWidget {
  final int mediaId;
  final Function(MediaListStatus) update;

  EditEntryPage(this.mediaId, this.update);

  @override
  _EditEntryPageState createState() => _EditEntryPageState();
}

class _EditEntryPageState extends State<EditEntryPage> {
  static const _box = SizedBox(width: 10, height: 10);

  CollectionProvider _collection;
  EntryUserData _oldData;
  EntryUserData _newData;
  Palette _palette;

  Widget _dual(Widget child1, Widget child2) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 75,
            child: child1,
          ),
        ),
        _box,
        Expanded(
          child: Container(
            height: 75,
            child: child2 ?? const SizedBox.expand(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _palette.background,
      appBar: CustomAppBar(
        title: 'Edit',
        trailing: [
          _UpdateButtons(
            oldData: _oldData,
            newData: _newData,
            collection: _collection,
            update: widget.update,
            palette: _palette,
          )
        ],
        wrapTrailing: false,
      ),
      body: _oldData != null
          ? ListView(
              padding: ViewConfig.PADDING,
              children: [
                _dual(
                  _EditField(
                    title: 'Status',
                    body: DropDownImplementation(_newData, _palette),
                    palette: _palette,
                  ),
                  _EditField(
                    title: 'Progress',
                    body: NumberField(
                      palette: _palette,
                      initialValue: _newData.progress,
                      maxValue: _newData.progressMax ?? 100000,
                      update: (progress) => _newData.progress = progress,
                    ),
                    palette: _palette,
                  ),
                ),
                _box,
                _dual(
                  _EditField(
                    title: 'Repeat',
                    body: NumberField(
                      palette: _palette,
                      initialValue: _newData.repeat,
                      update: (repeat) => _newData.repeat = repeat,
                    ),
                    palette: _palette,
                  ),
                  _oldData.type == 'MANGA'
                      ? _EditField(
                          title: 'Progress Volumes',
                          body: NumberField(
                            palette: _palette,
                            initialValue: _newData.progressVolumes,
                            maxValue: _newData.progressVolumesMax ?? 100000,
                            update: (progressVolumes) =>
                                _newData.progressVolumes = progressVolumes,
                          ),
                          palette: _palette,
                        )
                      : null,
                ),
                _box,
                _EditField(
                  title: 'Score',
                  body: ScoreField(),
                  palette: _palette,
                ),
              ],
            )
          : _box,
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

class _EditField extends StatelessWidget {
  static const _space = SizedBox(height: 5);

  final String title;
  final Widget body;
  final Palette palette;

  _EditField({
    @required this.title,
    @required this.body,
    @required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: palette.detail,
        ),
        _space,
        body,
      ],
    );
  }
}

class _UpdateButtons extends StatefulWidget {
  final EntryUserData oldData;
  final EntryUserData newData;
  final CollectionProvider collection;
  final Function(MediaListStatus) update;
  final Palette palette;

  _UpdateButtons({
    @required this.oldData,
    @required this.newData,
    @required this.collection,
    @required this.update,
    @required this.palette,
  });

  @override
  _UpdateButtonsState createState() => _UpdateButtonsState();
}

class _UpdateButtonsState extends State<_UpdateButtons> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return widget.oldData != null && !_isLoading
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBarIcon(
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: widget.palette.contrast,
                  iconSize: Palette.ICON_MEDIUM,
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: widget.palette.foreground,
                      title: Text(
                        'Remove entry?',
                        style: widget.palette.faded,
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
              ),
              AppBarIcon(
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
              ),
            ],
          )
        : const AppBarIcon(BlossomLoader(size: 30));
  }
}
