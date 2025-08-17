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
    final rail = NavigationRail(
      scrollable: true,
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
    );

    return ClipRect(
      child: BackdropFilter(filter: Theming.blurFilter, child: rail),
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
            surfaceTintColor: ColorScheme.of(context).surfaceTint,
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
    this.foregroundColor,
  });

  final String text;
  final IconData icon;
  final void Function() onTap;
  final Color? foregroundColor;

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
            foregroundColor: foregroundColor,
            iconColor: foregroundColor,
            iconSize: Theming.iconBig,
          ),
        ),
      ),
    );
  }
}
