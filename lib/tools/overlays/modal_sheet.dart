import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:otraku/providers/view_config.dart';

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
    return Container(
      height: options.length * 40 + 55.0,
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: ViewConfig.RADIUS,
      ),
      child: Column(
        children: <Widget>[
          Text(
            'Sort',
            style: Theme.of(context).textTheme.subtitle1,
          ),
          ..._options(context),
        ],
      ),
    );
  }

  List<Widget> _options(BuildContext context) {
    List<Widget> list = [];
    for (int i = 0; i < options.length; i++) {
      list.add(_ModalOption(
        text: options[i],
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
  final Function onTap;
  final bool desc;

  _ModalOption({
    @required this.text,
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
                  ? Theme.of(context).textTheme.headline3.copyWith(height: 1.0)
                  : Theme.of(context).textTheme.headline2.copyWith(height: 1.0),
            ),
            desc != null
                ? Icon(
                    desc
                        ? LineAwesomeIcons.arrow_down
                        : LineAwesomeIcons.arrow_up,
                    color: Theme.of(context).accentColor,
                  )
                : Icon(
                    LineAwesomeIcons.angle_down,
                    color: Theme.of(context).backgroundColor,
                  ),
          ],
        ),
      ),
      onTap: () => onTap(),
    );
  }
}
