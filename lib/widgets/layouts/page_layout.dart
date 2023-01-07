import 'package:flutter/material.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';

class PageLayout extends StatefulWidget {
  const PageLayout({
    required this.child,
    this.topBar,
    this.floatingBar,
    this.bottomBar,
  });

  final Widget child;
  final PreferredSizeWidget? topBar;
  final FloatingBar? floatingBar;
  final Widget? bottomBar;

  static PageLayoutState of(BuildContext context) {
    final PageLayoutState? result =
        context.findAncestorStateOfType<PageLayoutState>();
    if (result != null) return result;
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
        'PageLayout.of() called with a context that does not contain a PageLayout.',
      ),
      context.describeElement('The context used was'),
    ]);
  }

  @override
  State<PageLayout> createState() => PageLayoutState();
}

class PageLayoutState extends State<PageLayout> {
  double _topOffset = 0;
  double _bottomOffset = 0;
  bool _didCalculateOffsets = false;

  /// The offset from the top that this widget's children should avoid.
  /// It takes into consideration [viewPadding.top] of [MediaQueryData],
  /// the space taken by [widget.topBar] and the [topOffset] of the
  /// ancestral [PageLayoutState].
  double get topOffset => _topOffset;

  /// The offset from the bottom that this widget's children should avoid.
  /// It takes into consideration [viewPadding.bottom] of [MediaQueryData],
  /// the space taken by [widget.bottomBar] and the [bottomOffset] of the
  /// ancestral [PageLayoutState].
  double get bottomOffset => _bottomOffset;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didCalculateOffsets) return;
    _didCalculateOffsets = true;

    if (widget.topBar != null) {
      _topOffset += widget.topBar!.preferredSize.height;
    }

    if (widget.bottomBar != null) _bottomOffset += Consts.tapTargetSize;

    final pageLayout = context.findAncestorStateOfType<PageLayoutState>();
    if (pageLayout != null) {
      _topOffset += pageLayout._topOffset;
      _bottomOffset += pageLayout._bottomOffset;
    } else {
      _topOffset += MediaQuery.of(context).viewPadding.top;
      _bottomOffset += MediaQuery.of(context).viewPadding.bottom;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      appBar: widget.topBar,
      floatingActionButton: widget.floatingBar,
      bottomNavigationBar: widget.bottomBar,
      extendBody: true,
      extendBodyBehindAppBar: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      resizeToAvoidBottomInset: false,
    );
  }
}
