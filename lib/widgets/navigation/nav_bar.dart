import 'package:flutter/material.dart';
import 'package:otraku/utils/config.dart';

class NavBar extends StatefulWidget {
  final Map<IconData, String> options;
  final Function(int) onChanged;
  final int initial;

  NavBar({
    @required this.options,
    @required this.onChanged,
    this.initial = 0,
  });

  @override
  _NavBarState createState() => _NavBarState();

  static double offset(BuildContext ctx) =>
      MediaQuery.of(ctx).viewPadding.bottom + 60;
}

class _NavBarState extends State<NavBar> {
  int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initial;
  }

  @override
  void didUpdateWidget(covariant NavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _index = widget.initial;
  }

  @override
  Widget build(BuildContext context) => ClipRect(
        child: BackdropFilter(
          filter: Config.filter,
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
                for (int i = 0; i < widget.options.length; i++)
                  IconButton(
                    icon: Icon(widget.options.keys.elementAt(i)),
                    tooltip: widget.options.values.elementAt(i),
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
