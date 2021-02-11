import 'package:flutter/material.dart';
import 'package:otraku/enums/themes.dart';
import 'package:otraku/helpers/fn_helper.dart';

class CustomNavBar extends StatefulWidget {
  final List<IconData> icons;
  final Function(int) onChanged;
  final int Function() getIndex;
  final int initial;

  CustomNavBar({
    @required this.icons,
    @required this.onChanged,
    this.getIndex,
    this.initial = 0,
  });

  @override
  _CustomNavBarState createState() => _CustomNavBarState();

  static double offset(BuildContext ctx) =>
      MediaQuery.of(ctx).viewPadding.bottom + 60;
}

class _CustomNavBarState extends State<CustomNavBar> {
  int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.getIndex != null) _index = widget.getIndex();

    return ClipRect(
      child: BackdropFilter(
        filter: FnHelper.filter,
        child: Container(
          height: MediaQuery.of(context).viewPadding.bottom + 50,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewPadding.bottom,
          ),
          width: double.infinity,
          color: Theme.of(context).cardColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 0; i < widget.icons.length; i++)
                IconButton(
                  icon: Icon(widget.icons[i]),
                  iconSize: Styles.ICON_SMALL,
                  color: i != _index ? null : Theme.of(context).accentColor,
                  onPressed: () {
                    if (i != _index) {
                      widget.onChanged(i);
                      setState(() => _index = i);
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
