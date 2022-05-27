import 'package:flutter/material.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/widgets/drag_detector.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';

/// Hides the [child] on scroll-down and reveals it on scroll-up.
class FloatingBar extends StatefulWidget {
  FloatingBar({required this.scrollCtrl, required this.children});

  final List<Widget> children;
  final ScrollController scrollCtrl;

  @override
  _FloatingBarState createState() => _FloatingBarState();
}

class _FloatingBarState extends State<FloatingBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationCtrl;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  bool _visible = true;
  double _lastOffset = 0;

  void _visibility() {
    if (widget.scrollCtrl.positions.length != 1) return;

    final pos = widget.scrollCtrl.position;
    final dif = pos.pixels - _lastOffset;

    // If the position has moved enough from the last
    // spot or is out of bounds, update visibility.
    if (dif > 15 || pos.pixels > pos.maxScrollExtent) {
      _lastOffset = widget.scrollCtrl.position.pixels;
      _animationCtrl.forward().then((_) => setState(() => _visible = false));
    } else if (dif < -15 || pos.pixels < pos.minScrollExtent) {
      _lastOffset = widget.scrollCtrl.position.pixels;
      setState(() => _visible = true);
      _animationCtrl.reverse();
    }
  }

  @override
  void initState() {
    super.initState();
    _animationCtrl = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _slideAnimation = Tween(
      begin: Offset.zero,
      end: const Offset(0, 0.2),
    ).animate(_animationCtrl);
    _fadeAnimation = Tween(begin: 1.0, end: 0.3).animate(_animationCtrl);

    widget.scrollCtrl.addListener(_visibility);
  }

  @override
  void dispose() {
    widget.scrollCtrl.removeListener(_visibility);
    _animationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox();

    return Padding(
      padding: EdgeInsets.only(
        left: 15,
        right: 15,
        bottom: PageLayout.of(context).bottomOffset + 20,
      ),
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Row(
            mainAxisAlignment: Settings().leftHanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            children: Settings().leftHanded
                ? widget.children.reversed.toList()
                : widget.children,
          ),
        ),
      ),
    );
  }
}

const _actionButtonSize = 56.0;

/// An [FloatingActionButton] implementation.
class ActionButton extends StatelessWidget {
  ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.onSwipe,
  });

  final IconData icon;
  final String tooltip;
  final void Function() onTap;

  /// If not null, it will signal when the user swipes on the action button.
  /// Passing [true] means 'go right', while [false] means 'go left'. If the
  /// return value is not [null] the new [IconData] will replace the old one
  /// through an animation.
  final IconData? Function(bool)? onSwipe;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _actionButtonSize,
      height: _actionButtonSize,
      child: Tooltip(
        message: tooltip,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                blurRadius: 5,
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withAlpha(100),
              ),
            ],
          ),
          child: Material(
            color: Theme.of(context).colorScheme.primary,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(30),
              splashColor: Theme.of(context).colorScheme.primaryContainer,
              child: onSwipe == null
                  ? Icon(icon, color: Theme.of(context).colorScheme.onPrimary)
                  : _DraggableIcon(icon: icon, onSwipe: onSwipe!),
            ),
          ),
        ),
      ),
    );
  }
}

// Detects swiping and animates the icon switching.
class _DraggableIcon extends StatefulWidget {
  _DraggableIcon({
    required this.icon,
    required this.onSwipe,
  });

  final IconData icon;
  final IconData? Function(bool) onSwipe;

  @override
  State<_DraggableIcon> createState() => _DraggableIconState();
}

class _DraggableIconState extends State<_DraggableIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late IconData _icon;

  // The icon fades out on exit and fades in on entrance.
  late Animation<double> _opacity;

  // For when the icon exits/enters from the left.
  late Animation<Offset> _left;

  // For when the icon exits/enters from the right.
  late Animation<Offset> _right;

  bool _onRight = false;

  @override
  void initState() {
    super.initState();
    _icon = widget.icon;
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _opacity = Tween(begin: 1.0, end: 0.0).animate(_ctrl);

    _left = Tween(
      begin: Offset.zero,
      end: const Offset(-0.25, 0),
    ).animate(_ctrl);

    _right = Tween(
      begin: Offset.zero,
      end: const Offset(0.25, 0),
    ).animate(_ctrl);
  }

  @override
  void didUpdateWidget(covariant _DraggableIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    _icon = widget.icon;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DragDetector(
      triggerOffset: 10,
      onSwipe: (goRight) {
        // The previous transition must have finished.
        if (_ctrl.isAnimating) return;

        if (_onRight == goRight) setState(() => _onRight = !goRight);

        _ctrl.forward().then((_) {
          setState(() {
            _icon = widget.onSwipe(goRight) ?? _icon;
            _onRight = goRight;
          });
          _ctrl.reverse();
        });
      },
      child: SlideTransition(
        position: _onRight ? _right : _left,
        child: FadeTransition(
          opacity: _opacity,
          child: Icon(
            _icon,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}

class ActionMenu extends StatefulWidget {
  const ActionMenu({
    required this.items,
    required this.current,
    required this.onChanged,
  });

  final void Function(int) onChanged;
  final Map<String, IconData> items;
  final int current;

  @override
  State<ActionMenu> createState() => _ActionMenuState();
}

class _ActionMenuState extends State<ActionMenu> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.current;
  }

  @override
  void didUpdateWidget(covariant ActionMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    _index = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final full = constraints.maxWidth > widget.items.length * 150;
        final itemWidth = full ? 150.0 : 60.0;

        return Container(
          height: Consts.tapTargetSize,
          width: itemWidth * widget.items.length,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: Consts.borderRadiusMax,
            boxShadow: [
              BoxShadow(
                blurRadius: 5,
                color:
                    Theme.of(context).colorScheme.surfaceVariant.withAlpha(100),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedPositioned(
                left: itemWidth * _index,
                curve: Curves.easeOutCubic,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  width: itemWidth,
                  height: Consts.tapTargetSize,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: Consts.borderRadiusMax,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.background,
                      width: 5,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (int i = 0; i < widget.items.length; i++)
                    Flexible(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (_index == i) return;
                          setState(() => _index = i);
                          widget.onChanged(i);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.items.values.elementAt(i),
                              color: i != _index
                                  ? Theme.of(context).colorScheme.onBackground
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                            if (full) ...[
                              const SizedBox(width: 5),
                              Text(widget.items.keys.elementAt(i)),
                            ],
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
