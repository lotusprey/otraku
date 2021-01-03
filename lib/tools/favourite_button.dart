import 'package:flutter/material.dart';
import 'package:otraku/models/page_data/page_object.dart';

class FavoriteButton extends StatefulWidget {
  final PageObject data;
  final double shrinkPercentage;
  final Future<bool> Function() toggle;

  FavoriteButton(this.data, this.shrinkPercentage, this.toggle);

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.shrinkPercentage < 0.5)
          Opacity(
            opacity: 1 - widget.shrinkPercentage * 2,
            child: Text(
              widget.data.favourites.toString(),
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
        IconButton(
          icon: Icon(
            widget.data.isFavourite ? Icons.favorite : Icons.favorite_border,
            color: Theme.of(context).dividerColor,
          ),
          onPressed: () => widget.toggle().then((ok) => ok
              ? setState(
                  () => widget.data.isFavourite = !widget.data.isFavourite,
                )
              : null),
        ),
      ],
    );
  }
}
