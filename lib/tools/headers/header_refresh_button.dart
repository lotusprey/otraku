import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:otraku/providers/media_group_provider.dart';
import 'package:otraku/providers/theming.dart';

import '../blossom_loader.dart';

class HeaderRefreshButton extends StatelessWidget {
  final MediaGroupProvider listenable;
  final MediaGroupProvider readable;
  final Palette palette;

  HeaderRefreshButton({
    @required this.listenable,
    @required this.readable,
    @required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return listenable.isLoading
        ? const SizedBox(
            width: 48,
            child: Center(child: BlossomLoader(size: 30)),
          )
        : IconButton(
            icon: const Icon(LineAwesomeIcons.retweet),
            iconSize: Palette.ICON_MEDIUM,
            color: palette.faded,
            onPressed: readable.clear,
          );
  }
}
