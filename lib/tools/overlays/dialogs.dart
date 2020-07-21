import 'dart:ui';

import 'package:flutter/material.dart';

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
    return Dialog(
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
              color: Theme.of(context).backgroundColor,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Text(title, style: Theme.of(context).textTheme.headline4),
          ),
          Flexible(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(text, style: Theme.of(context).textTheme.bodyText1),
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
  final TextStyle style;
  final Image image;

  const ImageTextDialog({
    @required this.text,
    this.style,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(5);

    return Dialog(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      backgroundColor: Theme.of(context).primaryColor,
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
              style: style,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
