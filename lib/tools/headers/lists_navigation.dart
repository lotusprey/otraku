import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';

class ListsNavigation extends StatelessWidget {
  final List<String> titles;
  final List<int> subtitles;
  final int index;
  final Function(int) swipeResponse;
  final Function onHeaderTap;

  ListsNavigation({
    @required this.index,
    @required this.swipeResponse,
    @required this.onHeaderTap,
    @required this.titles,
    this.subtitles,
  });

  @override
  Widget build(BuildContext context) {
    DragStartDetails dragStart;
    DragUpdateDetails dragUpdate;

    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 30,
                child: IconButton(
                  padding: const EdgeInsets.all(0),
                  icon: const Icon(
                    FluentSystemIcons.ic_fluent_list_regular,
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ),
          ),
          GestureDetector(
            onHorizontalDragStart: (details) => dragStart = details,
            onHorizontalDragUpdate: (details) => dragUpdate = details,
            onHorizontalDragEnd: (_) {
              if (dragUpdate == null || dragStart == null) return;
              if (dragUpdate.globalPosition.dx < dragStart.globalPosition.dx) {
                if (index < titles.length - 1) swipeResponse(index + 1);
              } else {
                if (index > 0) swipeResponse(index - 1);
              }
            },
            onTap: onHeaderTap,
            child: Container(
              color: Colors.transparent,
              width: MediaQuery.of(context).size.width - 140,
              child: Center(
                child: Text(
                  titles[index],
                  style: Theme.of(context).textTheme.headline2,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: subtitles != null
                ? Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      subtitles[index].toString(),
                      style: Theme.of(context).textTheme.headline3,
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
