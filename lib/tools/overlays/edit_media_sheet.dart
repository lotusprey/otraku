import 'package:flutter/material.dart';
import 'package:otraku/enums/media_list_status_enum.dart';
import 'package:otraku/models/list_entry_user_data.dart';
import 'package:otraku/models/media_item_data.dart';
import 'package:otraku/providers/media_item.dart';
import 'package:otraku/providers/theming.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/custom_drop_down.dart';
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
              if (_data != null)
                _UpdateButton(
                  palette: _palette,
                  data: _data,
                  update: widget.update,
                ),
            ],
          ),
          if (_data != null)
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Status', style: _palette.smallTitle),
                      CustomDropDown(
                        options: widget.mediaObj.type == 'ANIME'
                            ? MediaListStatus.values
                                .map((v) => listStatusSpecification(v, true))
                                .toList()
                            : MediaListStatus.values
                                .map((v) => listStatusSpecification(v, false))
                                .toList(),
                        substituteText: 'Add',
                        startIndex: _data.mediaListStatus != null
                            ? _data.mediaListStatus.index
                            : null,
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
    Provider.of<MediaItem>(context, listen: false)
        .fetchUserData(widget.mediaObj.id)
        .then((data) => setState(() => _data = data));
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
            child: const WaveBarLoader(barWidth: 12),
          ),
        RaisedButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          color: widget.palette.accent,
          child: Text('Save', style: widget.palette.buttonText),
          onPressed: () {
            setState(() => _isLoading = true);
            //TODO
          },
        ),
      ],
    );
  }
}
