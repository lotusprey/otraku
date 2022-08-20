import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/consts.dart';
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

    if (widget.topBar != null)
      _topOffset += widget.topBar!.preferredSize.height;

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
    );
  }
}

/// A top app bar implementation that uses a blurred, translucent background.
/// [items] are the widgets that will appear on the top of it. If [canPop]
/// is true, a button that can pop the page will be placed before [items].
class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({this.items = const [], this.canPop = true, this.title});

  final bool canPop;
  final String? title;
  final List<Widget> items;

  @override
  Size get preferredSize => const Size.fromHeight(Consts.tapTargetSize);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: Consts.filter,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).bottomAppBarColor,
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).viewPadding.top,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: Consts.layoutBig),
                child: Material(
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      if (canPop)
                        TopBarIcon(
                          tooltip: 'Close',
                          icon: Ionicons.chevron_back_outline,
                          onTap: () => Navigator.maybePop(context),
                        )
                      else
                        const SizedBox(width: 10),
                      if (title != null)
                        Expanded(
                          child: Text(
                            title!,
                            style: Theme.of(context).textTheme.headline1,
                          ),
                        ),
                      ...items,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// An [IconButton] customised for a top app bar.
class TopBarIcon extends StatelessWidget {
  const TopBarIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.colour,
  });

  final IconData icon;
  final String tooltip;
  final Color? colour;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: onTap,
      iconSize: Consts.iconBig,
      color: colour ?? Theme.of(context).colorScheme.onBackground,
      constraints: const BoxConstraints(maxWidth: 45, maxHeight: 45),
      padding: Consts.padding,
    );
  }
}
