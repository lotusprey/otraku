import 'package:flutter/material.dart';
import 'package:otraku/enums/media_list_status_enum.dart';
import 'package:otraku/models/media_object.dart';

class ActionControls extends StatefulWidget {
  final MediaObject mediaObject;

  ActionControls(this.mediaObject);

  @override
  _ActionControlsState createState() => _ActionControlsState();
}

class _ActionControlsState extends State<ActionControls> {
  Widget _button({
    IconData icon,
    Color color,
    Function function,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: color,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 30,
          color: Colors.white,
        ),
        onPressed: () => function(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizedBox = const SizedBox(width: 10);

    final bool isInList =
        widget.mediaObject.mediaListStatus != MediaListStatus.None;
    final bool isFavorited = widget.mediaObject.isFavourite;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _button(
          icon: Icons.keyboard_arrow_left,
          color: Theme.of(context).accentColor,
          function: () => Navigator.of(context).pop(),
        ),
        sizedBox,
        _button(
          icon: !isInList ? Icons.add : Icons.edit,
          color: Theme.of(context).accentColor,
          function: () {},
        ),
        sizedBox,
        _button(
          icon: !isFavorited ? Icons.favorite_border : Icons.favorite,
          color: Theme.of(context).errorColor,
          function: () => widget.mediaObject
              .toggleFavourite(context)
              .then((value) => setState(() {})),
        ),
      ],
    );
  }
}

class DisableAnimationAnimator extends FloatingActionButtonAnimator {
  const DisableAnimationAnimator();

  @override
  Offset getOffset({Offset begin, Offset end, double progress}) {
    return end;
  }

  @override
  Animation<double> getRotationAnimation({Animation<double> parent}) {
    return Tween<double>(begin: 1.0, end: 1.0).animate(parent);
  }

  @override
  Animation<double> getScaleAnimation({Animation<double> parent}) {
    return Tween<double>(begin: 1.0, end: 1.0).animate(parent);
  }
}
