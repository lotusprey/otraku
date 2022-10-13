import 'package:flutter/material.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/utils/options.dart';
import 'package:otraku/widgets/drag_detector.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';

/// Hides the [child] on scroll-down and reveals it on scroll-up.
class FloatingBar extends StatefulWidget {
  const FloatingBar({
    required this.scrollCtrl,
    required this.children,
    this.centered = false,
  });

  final List<Widget> children;
  final ScrollController scrollCtrl;
  final bool centered;

  @override
  FloatingBarState createState() => FloatingBarState();
}

class FloatingBarState extends State<FloatingBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationCtrl;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  bool _visible = true;
  double _lastOffset = 0;

  void _visibility() {
    final pos = widget.scrollCtrl.positions.last;
    final dif = pos.pixels - _lastOffset;

    // If the position has moved enough from the last
    // spot or is out of bounds, update visibility.
    if (dif > 15 || pos.pixels > pos.maxScrollExtent) {
      _lastOffset = pos.pixels;
      _animationCtrl.forward().then((_) => setState(() => _visible = false));
    } else if (dif < -15 || pos.pixels < pos.minScrollExtent) {
      _lastOffset = pos.pixels;
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

    final children = Options().leftHanded
        ? widget.children
        : widget.children.reversed.toList();

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
            mainAxisAlignment: widget.centered
                ? MainAxisAlignment.center
                : Options().leftHanded
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end,
            children: [
              for (int i = 0; i < children.length; i++) ...[
                const SizedBox(width: 10),
                children[i],
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class ActionTabSwitcher extends StatefulWidget {
  const ActionTabSwitcher({
    required this.items,
    required this.current,
    required this.onChanged,
  });

  final int current;
  final List<String> items;
  final void Function(int) onChanged;

  @override
  State<ActionTabSwitcher> createState() => _ActionTabSwitcherState();
}

class _ActionTabSwitcherState extends State<ActionTabSwitcher> {
  late int _index = widget.current;

  @override
  void didUpdateWidget(covariant ActionTabSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    _index = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    final itemRow = Row(
      children: [
        for (int i = 0; i < widget.items.length; i++)
          Flexible(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: Consts.borderRadiusMax,
                onTap: () {
                  if (_index == i) return;
                  setState(() => _index = i);
                  widget.onChanged(i);
                },
                child: Center(
                  child: Text(
                    widget.items[i],
                    overflow: TextOverflow.ellipsis,
                    style: i != _index
                        ? Theme.of(context).textTheme.headline2
                        : Theme.of(context).textTheme.headline2?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    return Flexible(
      child: LayoutBuilder(
        builder: (context, constraints) {
          double itemWidth = (constraints.maxWidth - 20) / widget.items.length;
          if (itemWidth > 150) itemWidth = 150;

          return Container(
            height: Consts.tapTargetSize,
            width: itemWidth * widget.items.length,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: Consts.borderRadiusMax,
              boxShadow: [
                BoxShadow(
                  blurRadius: 5,
                  color: Theme.of(context).colorScheme.surfaceVariant,
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
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: Consts.borderRadiusMax,
                      border: Border.all(
                        width: 5,
                        color: Theme.of(context).colorScheme.background,
                      ),
                    ),
                  ),
                ),
                itemRow,
              ],
            ),
          );
        },
      ),
    );
  }
}

const actionButtonSize = 56.0;

/// An [FloatingActionButton] implementation.
class ActionButton extends StatelessWidget {
  const ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.onSwipe,
  });

  final IconData icon;
  final String tooltip;
  final void Function() onTap;

  /// If not null, it will signal when the user swipes on the action button.
  /// Passing `true` means 'go right', while `false` means 'go left'. If the
  /// return value is not `null` the new [IconData] will replace the old one
  /// through an animation.
  final IconData? Function(bool)? onSwipe;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: actionButtonSize,
      height: actionButtonSize,
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
              splashColor:
                  Theme.of(context).colorScheme.onPrimary.withAlpha(50),
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
  const _DraggableIcon({
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
