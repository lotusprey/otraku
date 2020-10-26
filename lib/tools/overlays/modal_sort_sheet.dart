import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otraku/enums/theme_enum.dart';
import 'package:otraku/providers/view_config.dart';

class ModalSortSheet extends StatelessWidget {
  final List<String> options;
  final int index;
  final bool desc;
  final Function(int) onTap;

  ModalSortSheet({
    @required this.options,
    @required this.index,
    @required this.desc,
    @required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: options.length * 35 + 20.0,
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: ViewConfig.BORDER_RADIUS,
      ),
      child: Column(
        children: <Widget>[
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
                        ? FluentSystemIcons.ic_fluent_arrow_down_filled
                        : FluentSystemIcons.ic_fluent_arrow_up_filled,
                    size: Styles.ICON_SMALL,
                    color: Theme.of(context).accentColor,
                  )
                : Icon(
                    FluentSystemIcons.ic_fluent_arrow_down_filled,
                    size: Styles.ICON_SMALL,
                    color: Theme.of(context).backgroundColor,
                  ),
          ],
        ),
      ),
      onTap: () => onTap(),
    );
  }
}
