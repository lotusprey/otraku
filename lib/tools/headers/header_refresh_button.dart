import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:otraku/providers/design.dart';
import 'package:otraku/providers/media_group_provider.dart';
import 'package:otraku/providers/view_config.dart';

import '../blossom_loader.dart';

class HeaderRefreshButton extends StatelessWidget {
  final MediaGroupProvider listenable;
  final MediaGroupProvider readable;

  HeaderRefreshButton({
    @required this.listenable,
    @required this.readable,
  });

  @override
  Widget build(BuildContext context) {
    return listenable.isLoading
        ? const SizedBox(
            width: ViewConfig.MATERIAL_TAP_TARGET_SIZE,
            child: Center(child: BlossomLoader(size: 30)),
          )
        : IconButton(
            icon: const Icon(FeatherIcons.refreshCw),
            iconSize: Design.ICON_SMALL,
            onPressed: readable.clear,
          );
  }
}
