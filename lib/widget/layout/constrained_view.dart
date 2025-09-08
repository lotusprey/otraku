import 'package:flutter/widgets.dart';
import 'package:otraku/util/theming.dart';

/// Horizontally constrains [child] in the center.
class ConstrainedView extends StatelessWidget {
  const ConstrainedView({required this.child, this.padded = true});

  final Widget child;
  final bool padded;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padded ? const EdgeInsets.symmetric(horizontal: Theming.offset) : EdgeInsets.zero,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: Theming.windowWidthMedium,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// An alternative to [ConstrainedView] for Sliver views.
class SliverConstrainedView extends StatelessWidget {
  const SliverConstrainedView({required this.sliver});

  final Widget sliver;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final side = (constraints.crossAxisExtent - Theming.windowWidthMedium) / 2;

        return SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: side < Theming.offset ? Theming.offset : side,
          ),
          sliver: sliver,
        );
      },
    );
  }
}
