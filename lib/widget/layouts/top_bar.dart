import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/extension/build_context_extension.dart';
import 'package:otraku/util/theming.dart';

/// A top app bar implementation that uses a blurred, translucent background.
class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({this.title, this.trailing = const []});

  final String? title;
  final List<Widget> trailing;

  @override
  Size get preferredSize => const Size.fromHeight(Theming.normalTapTarget);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return ClipRect(
      child: BackdropFilter(
        filter: Theming.blurFilter,
        child: Container(
          height: topPadding + preferredSize.height,
          decoration: BoxDecoration(
            color: Theme.of(context).navigationBarTheme.backgroundColor,
          ),
          padding: EdgeInsets.only(top: topPadding),
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
                    style: Theme.of(context).textTheme.titleLarge,
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
