import 'package:flutter/material.dart';
import 'package:otraku/util/theming.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({
    required this.current,
    required this.items,
    required this.onChanged,
    required this.onSame,
  });

  final int current;
  final Map<String, IconData> items;
  final void Function(int) onChanged;
  final void Function(int) onSame;

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _selected = widget.current;

  @override
  void didUpdateWidget(covariant BottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _selected = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: Theming.blurFilter,
        child: NavigationBar(
          height: BottomBar.height,
          selectedIndex: _selected,
          onDestinationSelected: (i) {
            if (_selected == i) {
              widget.onSame(i);
            } else {
              _selected = i;
              widget.onChanged(_selected);
            }
          },
          destinations: [
            for (final t in widget.items.entries)
              NavigationDestination(label: t.key, icon: Icon(t.value))
          ],
        ),
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  const BottomBar(this.items);

  final List<Widget> items;

  static const height = 60.0;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: Theming.blurFilter,
        child: SizedBox(
          height: height + bottomPadding,
          child: Material(
            elevation: 3,
            color: Theme.of(context).navigationBarTheme.backgroundColor,
            surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
            shadowColor: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: Row(children: items),
            ),
          ),
        ),
      ),
    );
  }
}

class BottomBarButton extends StatelessWidget {
  const BottomBarButton({
    required this.text,
    required this.icon,
    required this.onTap,
    this.warning = false,
  });

  final String text;
  final IconData icon;
  final void Function() onTap;

  /// If the icon/text should be in the error colour.
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Theming.offset),
        child: TextButton.icon(
          label: Text(text),
          icon: Icon(icon),
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor:
                warning ? Theme.of(context).colorScheme.error : null,
          ),
        ),
      ),
    );
  }
}
