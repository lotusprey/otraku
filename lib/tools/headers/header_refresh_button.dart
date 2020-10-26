import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HeaderRefreshButton extends StatelessWidget {
  // final MediaGroupProvider listenable;
  // final MediaGroupProvider readable;

  // HeaderRefreshButton({
  //   @required this.listenable,
  //   @required this.readable,
  // });

  @override
  Widget build(BuildContext context) {
    return SizedBox();

    // return listenable.isLoading
    //     ? const SizedBox(
    //         width: ViewConfig.MATERIAL_TAP_TARGET_SIZE,
    //         child: Center(child: BlossomLoader(size: 30)),
    //       )
    //     : IconButton(
    //         icon:
    //             const Icon(FluentSystemIcons.ic_fluent_arrow_repeat_all_filled),
    //         iconSize: Design.ICON_SMALL,
    //         onPressed: () {},
    //         onPressed: readable.clear,
    //       );
  }
}
