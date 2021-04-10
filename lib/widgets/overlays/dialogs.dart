import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:otraku/utils/config.dart';

class PopUpAnimation extends StatefulWidget {
  final Widget child;

  const PopUpAnimation(this.child);

  @override
  _PopUpAnimationState createState() => _PopUpAnimationState();
}

class _PopUpAnimationState extends State<PopUpAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
      value: 0.1,
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: _anim,
        child: widget.child,
      );
}

class TextDialog extends StatelessWidget {
  final String title;
  final String text;

  const TextDialog({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
      backgroundColor: Theme.of(context).backgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: Config.BORDER_RADIUS),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 1000),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Config.RADIUS),
                color: Theme.of(context).backgroundColor,
              ),
              padding: Config.PADDING,
              child: Text(title, style: Theme.of(context).textTheme.subtitle1),
            ),
            Flexible(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Config.RADIUS),
                  color: Theme.of(context).primaryColor,
                ),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    physics: Config.PHYSICS,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageDialog extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const ImageDialog(this.url, [this.fit = BoxFit.cover]);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
      shape: const RoundedRectangleBorder(borderRadius: Config.BORDER_RADIUS),
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: Config.BORDER_RADIUS,
        child: Image.network(url, fit: fit),
      ),
    );
  }
}

class ImageTextDialog extends StatelessWidget {
  final String? text;
  final Image? image;

  const ImageTextDialog({
    required this.text,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
      shape: const RoundedRectangleBorder(borderRadius: Config.BORDER_RADIUS),
      backgroundColor: Theme.of(context).primaryColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(borderRadius: Config.BORDER_RADIUS, child: image),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: SelectableText(
              text!,
              style: Theme.of(context).textTheme.headline3,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
