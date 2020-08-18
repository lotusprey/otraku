import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:otraku/providers/theming.dart';
import 'package:provider/provider.dart';

class ModalSheet extends StatelessWidget {
  final List<String> options;
  final int index;
  final bool desc;
  final Function(int) onTap;

  ModalSheet({
    @required this.options,
    @required this.index,
    @required this.desc,
    @required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<Theming>(context, listen: false).palette;

    return Container(
      height: 400,
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
            ..._options(palette, context),
          ],
        ),
      ),
    );
  }

  List<Widget> _options(Palette palette, BuildContext context) {
    List<Widget> list = [];
    for (int i = 0; i < options.length; i++) {
      list.add(_ModalOption(
        text: options[i],
        palette: palette,
        desc: index == i ? desc : null,
        onTap: () {
          onTap(i);
          Navigator.of(context).pop();
        },
      ));
    }
    return list;
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
              style: desc == null
                  ? palette.titleContrasted
                  : palette.titleAccented,
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
