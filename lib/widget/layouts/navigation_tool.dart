import 'package:flutter/material.dart';
import 'package:otraku/util/theming.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({
    required this.selected,
    required this.items,
    required this.onChanged,
    required this.onSame,
  });

  final int selected;
  final Map<String, IconData> items;
  final void Function(int) onChanged;
  final void Function(int) onSame;

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  late int _selected = widget.selected;

  @override
  void didUpdateWidget(covariant BottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    _selected = widget.selected;
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
            for (final e in widget.items.entries)
              NavigationDestination(label: e.key, icon: Icon(e.value))
          ],
        ),
      ),
    );
  }
}

class SideNavigation extends StatefulWidget {
  const SideNavigation({
    required this.selected,
    required this.items,
    required this.onChanged,
    required this.onSame,
  });

  final int selected;
  final Map<String, IconData> items;
  final void Function(int) onChanged;
  final void Function(int) onSame;

  @override
  State<SideNavigation> createState() => _SideNavigationState();
}

class _SideNavigationState extends State<SideNavigation> {
  late int _selected = widget.selected;

  @override
  void didUpdateWidget(covariant SideNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: Theming.blurFilter,
        child: NavigationRail(
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
            for (final e in widget.items.entries)
              NavigationRailDestination(label: Text(e.key), icon: Icon(e.value))
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
