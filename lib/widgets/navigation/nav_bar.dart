import 'package:flutter/material.dart';
import 'package:otraku/utils/config.dart';

class NavBar extends StatefulWidget {
  final Map<String, IconData> items;
  final void Function(int) onChanged;
  final int initial;

  NavBar({
    required this.items,
    required this.onChanged,
    this.initial = 0,
  });

  @override
  _NavBarState createState() => _NavBarState();

  // At the bottom of a page there should be this offset
  // in order to avoid obstruction by the navbar.
  static double offset(BuildContext ctx) =>
      MediaQuery.of(ctx).viewPadding.bottom + 60;
}

class _NavBarState extends State<NavBar> {
  late int _index;

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
  Widget build(BuildContext context) {
    final full = MediaQuery.of(context).size.width > widget.items.length * 130;

    return ClipRect(
      child: BackdropFilter(
        filter: Config.filter,
        child: Container(
          height: MediaQuery.of(context).viewPadding.bottom + 50,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewPadding.bottom,
          ),
          color: Theme.of(context).cardColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 0; i < widget.items.length; i++)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (i == _index) return;
                    widget.onChanged(i);
                    setState(() => _index = i);
                  },
                  child: SizedBox(
                    height: double.infinity,
                    width: full ? 130 : 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.items.values.elementAt(i),
                          color: i != _index
                              ? null
                              : Theme.of(context).colorScheme.secondary,
                        ),
                        if (full) ...[
                          const SizedBox(width: 5),
                          Text(
                            widget.items.keys.elementAt(i),
                            style: i != _index
                                ? Theme.of(context).textTheme.subtitle1
                                : Theme.of(context).textTheme.bodyText1,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
