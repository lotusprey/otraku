import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:otraku/enums/theme_enum.dart';

class CustomNavBar extends StatefulWidget {
  final List<IconData> icons;
  final Function(int) onChanged;
  final int initial;

  CustomNavBar({
    @required this.icons,
    @required this.onChanged,
    this.initial = 0,
  });

  @override
  _CustomNavBarState createState() => _CustomNavBarState();
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
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 50,
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
