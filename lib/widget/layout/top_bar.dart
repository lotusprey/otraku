import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/extension/build_context_extension.dart';
import 'package:otraku/util/theming.dart';

const _preferredSize = Size.fromHeight(Theming.normalTapTarget);

/// A top app bar implementation that uses a blurred, translucent background.
class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({super.key, this.title, this.trailing = const []});

  final String? title;
  final List<Widget> trailing;

  @override
  Size get preferredSize => _preferredSize;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return ClipRect(
      child: BackdropFilter(
        filter: Theming.blurFilter,
        child: Container(
          height: topPadding + preferredSize.height,
          decoration: BoxDecoration(color: Theme.of(context).navigationBarTheme.backgroundColor),
          padding: .only(top: topPadding),
          alignment: Alignment.center,
          child: Row(
            children: [
              if (GoRouter.of(context).canPop())
                IconButton(
                  tooltip: 'Close',
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  onPressed: context.back,
                )
              else
                const SizedBox(width: Theming.offset),
              if (title != null)
                Expanded(
                  child: Text(
                    title!,
                    style: TextTheme.of(context).titleLarge,
                    overflow: .ellipsis,
                    maxLines: 2,
                  ),
                ),
              ...trailing,
            ],
          ),
        ),
      ),
    );
  }
}

/// Dummy widget for when the app bar changes depending on the current tab
/// and a tab doesn't have an associated app bar.
class EmptyTopBar extends StatelessWidget implements PreferredSizeWidget {
  const EmptyTopBar();

  @override
  Size get preferredSize => _preferredSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: MediaQuery.paddingOf(context).top + _preferredSize.height);
  }
}

/// An [AnimatedSwitcher] wrapper around any [PreferredSizeWidget].
/// Used for app bars that change depending on the current page tab.
class TopBarAnimatedSwitcher extends StatelessWidget implements PreferredSizeWidget {
  const TopBarAnimatedSwitcher(this.child);

  final PreferredSizeWidget? child;

  @override
  Size get preferredSize => child?.preferredSize ?? const Size.fromHeight(0);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: child);
  }
}
