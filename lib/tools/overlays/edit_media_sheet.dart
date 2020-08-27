import 'package:flutter/material.dart';
import 'package:otraku/models/list_entry_user_data.dart';
import 'package:otraku/models/media_item_data.dart';
import 'package:otraku/providers/media_item.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/wave_bar_loader.dart';
import 'package:provider/provider.dart';

class EditMediaSheet extends StatefulWidget {
  final Function(ListEntryUserData) update;
  final MediaItemData mediaObj;

  EditMediaSheet(this.update, this.mediaObj);

  @override
  _EditMediaSheetState createState() => _EditMediaSheetState();
}

class _EditMediaSheetState extends State<EditMediaSheet> {
  bool _isLoading = true;

  ListEntryUserData _data;
  Palette _palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: Provider.of<ViewConfig>(context, listen: false).topInset + 20,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
              if (!_isLoading)
                _UpdateButton(
                  palette: _palette,
                  data: _data,
                  update: widget.update,
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Provider.of<MediaItem>(context, listen: false)
        .fetchUserData(widget.mediaObj.id);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _palette = Provider.of<Theming>(context).palette;
  }
}

class _UpdateButton extends StatefulWidget {
  final Palette palette;
  final ListEntryUserData data;
  final Function(ListEntryUserData) update;

  _UpdateButton({
    @required this.palette,
    @required this.data,
    @required this.update,
  });

  @override
  __UpdateButtonState createState() => __UpdateButtonState();
}

class __UpdateButtonState extends State<_UpdateButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isLoading)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: WaveBarLoader(barWidth: 12),
          ),
        RaisedButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          color: widget.palette.accent,
          child: Text('Save', style: widget.palette.buttonText),
          onPressed: () {
            //TODO
          },
        ),
      ],
    );
  }
}

class _Content extends StatefulWidget {
  final Palette palette;

  _Content(this.palette);

  @override
  __ContentState createState() => __ContentState();
}

class __ContentState extends State<_Content> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return _isLoading ? Container() : Container();
  }

  @override
  void initState() {
    super.initState();
  }
}
