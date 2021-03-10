import 'package:flutter/material.dart';

class FavoriteButton extends StatefulWidget {
  final int favourites;
  final bool isFavourite;
  final double shrinkPercentage;
  final Future<bool> Function() toggle;

  FavoriteButton({
    @required this.favourites,
    @required this.isFavourite,
    @required this.shrinkPercentage,
    @required this.toggle,
  });

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _isFavourite;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.shrinkPercentage < 0.5)
          Opacity(
            opacity: 1 - widget.shrinkPercentage * 2,
            child: Text(
              widget.favourites.toString(),
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
        IconButton(
          tooltip: _isFavourite ? 'UnFavourite' : 'Favourite',
          icon: Icon(
            _isFavourite ? Icons.favorite : Icons.favorite_border,
            color: Theme.of(context).dividerColor,
          ),
          onPressed: () => widget.toggle().then(
              (ok) => ok ? setState(() => _isFavourite = !_isFavourite) : null),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _isFavourite = widget.isFavourite;
  }
}
