import 'package:flutter/material.dart';
import 'package:otraku/models/entry_user_data.dart';
import 'package:otraku/providers/media_item.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/tools/overlays/edit_media_tools/drop_down_implementation.dart';
import 'package:otraku/tools/overlays/edit_media_tools/grid_child.dart';
import 'package:otraku/tools/overlays/edit_media_tools/number_field.dart';
import 'package:otraku/tools/overlays/edit_media_tools/save_button.dart';
import 'package:provider/provider.dart';

class EditEntryPage extends StatefulWidget {
  final int mediaId;
  final Function(EntryUserData) update;

  EditEntryPage(this.mediaId, this.update);

  @override
  _EditEntryPageState createState() => _EditEntryPageState();
}

class _EditEntryPageState extends State<EditEntryPage> {
  EntryUserData _oldData;
  EntryUserData _newData;
  Palette _palette;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _palette.background,
      appBar: AppBar(
        backgroundColor: _palette.background,
        shadowColor: _palette.background,
        leading: IconButton(
          icon: const Icon(Icons.close),
          color: _palette.contrast,
          iconSize: Palette.ICON_MEDIUM,
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text('Edit', style: _palette.contrastedTitle),
        actions: _oldData != null
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: Palette.ERROR,
                  iconSize: Palette.ICON_MEDIUM,
                  onPressed: () {},
                ),
                SaveButton(
                  oldData: _oldData,
                  newData: _newData,
                  palette: _palette,
                  update: widget.update,
                ),
              ]
            : null,
      ),
      body: _oldData != null
          ? Padding(
              padding: const EdgeInsets.all(10),
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
