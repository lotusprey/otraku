import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:otraku/enums/media_sort_enum.dart';
import 'package:otraku/providers/theming.dart';
import 'package:provider/provider.dart';

class SortModalSheet extends StatelessWidget {
  final Map<String, dynamic> _filters;
  final Function _loadMedia;

  SortModalSheet(this._filters, this._loadMedia);

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<Theming>(context, listen: false).palette;
    MediaSort mediaSort;

    try {
      mediaSort = getMediaSortFromString(_filters['sort']);
    } catch (e) {}

    return Container(
      height: 380,
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: palette.primary,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          children: <Widget>[
            Text(
              'Sort',
              style: palette.titleSmall,
            ),
            ..._options(palette, context, mediaSort),
          ],
        ),
      ),
    );
  }

  List<Widget> _options(
    Palette palette,
    BuildContext context,
    MediaSort mediaSort,
  ) {
    List<Widget> options = [];
    for (int i = 0; i < MediaSort.values.length; i += 2) {
      if (mediaSort == MediaSort.values[i]) {
        options.add(_ModalOption(
          text: mediaSort.tuple.item1,
          palette: palette,
          onTap: () => _changeSort(context, MediaSort.values[i + 1]),
          desc: false,
        ));
      } else if (mediaSort == MediaSort.values[i + 1]) {
        options.add(_ModalOption(
          text: mediaSort.tuple.item1,
          palette: palette,
          onTap: () => _changeSort(context, MediaSort.values[i]),
          desc: true,
        ));
      } else {
        options.add(_ModalOption(
          text: MediaSort.values[i].tuple.item1,
          palette: palette,
          onTap: () => _changeSort(context, MediaSort.values[i + 1]),
        ));
      }
    }
    return options;
  }

  void _changeSort(BuildContext context, MediaSort mediaSort) {
    _filters['sort'] = describeEnum(mediaSort);
    Navigator.of(context).pop();
    _loadMedia();
  }
}

class _ModalOption extends StatelessWidget {
  final String text;
  final Palette palette;
  final Function onTap;
  final bool desc;

  _ModalOption({
    @required this.text,
    @required this.palette,
    @required this.onTap,
    this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              text,
              style: desc == null ? palette.titleInactive : palette.titleActive,
            ),
            desc != null
                ? Icon(
                    desc
                        ? LineAwesomeIcons.angle_down
                        : LineAwesomeIcons.angle_up,
                    color: palette.accent,
                    size: Palette.ICON_MEDIUM,
                  )
                : Icon(
                    LineAwesomeIcons.angle_down,
                    color: palette.primary,
                    size: Palette.ICON_MEDIUM,
                  ),
          ],
        ),
      ),
      onTap: () => onTap(),
    );
  }
}
