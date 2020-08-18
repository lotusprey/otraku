import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:otraku/providers/theming.dart';
import 'package:provider/provider.dart';

class PopUpAnimation extends StatefulWidget {
  final Widget child;

  const PopUpAnimation(this.child);

  @override
  _PopUpAnimationState createState() => _PopUpAnimationState();
}

class _PopUpAnimationState extends State<PopUpAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(
        milliseconds: 150,
      ),
      vsync: this,
      value: 0.1,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}

class TextDialog extends StatelessWidget {
  final String title;
  final String text;

  const TextDialog({this.title, this.text});

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<Theming>(context, listen: false).palette;

    return Dialog(
      elevation: 0,
      backgroundColor: palette.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
              color: palette.primary,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Text(title, style: palette.headlineMain),
          ),
          Flexible(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(5)),
                color: palette.background,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(text, style: palette.paragraph),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ImageDialog extends StatelessWidget {
  final Image image;

  const ImageDialog(this.image);

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(5);

    return Dialog(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: image,
      ),
    );
  }
}

class ImageTextDialog extends StatelessWidget {
  final String text;
  final Image image;

  const ImageTextDialog({
    @required this.text,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<Theming>(context, listen: false).palette;
    final borderRadius = BorderRadius.circular(5);

    return Dialog(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      backgroundColor: palette.primary,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ClipRRect(
            borderRadius: borderRadius,
            child: image,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              text,
              style: palette.titleContrasted,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
