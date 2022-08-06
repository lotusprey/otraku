import 'package:flutter/material.dart';

/// A wrapper around [PageView] that skips over unnecessary
/// tabs when animating through multiple of them.
class DirectPageView extends StatefulWidget {
  const DirectPageView({
    required this.children,
    required this.current,
    required this.onChanged,
  });

  final List<Widget> children;
  final int current;

  /// If `null` the tabs can't be swiped, but they will
  /// still animate, when [current] is changed externally.
  final void Function(int)? onChanged;

  @override
  State<DirectPageView> createState() => _DirectPageViewState();
}

class _DirectPageViewState extends State<DirectPageView> {
  late final PageController _ctrl;

  /// While [DirectPageView] is performing a switch triggered from the outside,
  /// [_busy] is set to `true` to signal that [widget.onChanged] shouldn't be
  /// called, as the outer environment already knows about the tab change.
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(initialPage: widget.current);
  }

  @override
  void didUpdateWidget(covariant DirectPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _animateToCurrent();
  }

  /// Animate to any other tab as if it was a neighbouring one.
  Future<void> _animateToCurrent() async {
    final page = _ctrl.page?.round() ?? 0;
    _busy = true;

    if (widget.current == page + 1) {
      await _ctrl.animateToPage(
        page + 1,
        curve: Curves.easeOutExpo,
        duration: const Duration(milliseconds: 200),
      );
    } else if (widget.current == page - 1) {
      await _ctrl.animateToPage(
        page - 1,
        curve: Curves.easeOutExpo,
        duration: const Duration(milliseconds: 200),
      );
    } else if (widget.current > page) {
      final temp = widget.children[page + 1];
      widget.children[page + 1] = widget.children[widget.current];

      await _ctrl.animateToPage(
        page + 1,
        curve: Curves.easeOutExpo,
        duration: const Duration(milliseconds: 200),
      );

      setState(() {
        widget.children[page + 1] = temp;
        _ctrl.jumpToPage(widget.current);
      });
    } else if (widget.current < page) {
      final temp = widget.children[page - 1];
      widget.children[page - 1] = widget.children[widget.current];

      await _ctrl.animateToPage(
        page - 1,
        curve: Curves.easeOutExpo,
        duration: const Duration(milliseconds: 200),
      );

      setState(() {
        widget.children[page - 1] = temp;
        _ctrl.jumpToPage(widget.current);
      });
    }

    _busy = false;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _ctrl,
      children: widget.children,
      physics: widget.onChanged == null
          ? const NeverScrollableScrollPhysics()
          : null,
      onPageChanged: (int i) {
        if (_busy) return;
        widget.onChanged?.call(i);
      },
    );
  }
}
