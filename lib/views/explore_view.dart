import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/explore_controller.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/reviews/review_grid.dart';
import 'package:otraku/widgets/grids/title_grid.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/grids/tile_grid.dart';
import 'package:otraku/widgets/navigation/filter_tools.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class ExploreView extends StatelessWidget {
  ExploreView(this.scrollCtrl);

  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExploreController>(
      builder: (ctrl) => PageLayout(
        floatingBar: FloatingBar(
          scrollCtrl: scrollCtrl,
          children: const [ExploreActionButton()],
        ),
        topBar: TopBar(
          canPop: false,
          items: [
            GetBuilder<ExploreController>(
              id: ExploreController.ID_HEAD,
              builder: (ctrl) => SearchToolField(
                value: ctrl.search,
                title: Convert.clarifyEnum(ctrl.type.name)!,
                onChanged: ctrl.type != Explorable.review
                    ? (val) => ctrl.search = val
                    : null,
              ),
            ),
            GetBuilder<ExploreController>(
              id: ExploreController.ID_HEAD,
              builder: (ctrl) {
                if (ctrl.type == Explorable.anime ||
                    ctrl.type == Explorable.manga)
                  return FilterMediaToolButton(ctrl.filters);

                if (ctrl.type == Explorable.character ||
                    ctrl.type == Explorable.staff)
                  return _BirthdayFilter(
                    value: ctrl.isBirthday,
                    onChanged: (val) => ctrl.isBirthday = val,
                  );

                return const SizedBox(width: 10);
              },
            ),
          ],
        ),
        child: _ExploreGrid(ctrl, scrollCtrl),
      ),
    );
  }
}

class _ExploreGrid extends StatelessWidget {
  _ExploreGrid(this.ctrl, this.scrollCtrl);

  final ExploreController ctrl;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final refreshControl = SliverRefreshControl(
      onRefresh: ctrl.fetch,
      canRefresh: () => !ctrl.isLoading,
    );

    final footer = SliverFooter(loading: ctrl.hasNextPage);

    return GetBuilder<ExploreController>(
      id: ExploreController.ID_BODY,
      builder: (ctrl) {
        if (ctrl.isLoading) return const Center(child: Loader());

        final results = ctrl.results;
        if (results.isEmpty) return const Center(child: Text('No results'));

        if (results[0].explorable == Explorable.studio)
          return CustomScrollView(
            physics: Consts.physics,
            controller: scrollCtrl,
            slivers: [refreshControl, TitleGrid(results), footer],
          );

        if (results[0].explorable == Explorable.user)
          return CustomScrollView(
            physics: Consts.physics,
            controller: scrollCtrl,
            slivers: [
              refreshControl,
              TileGrid(models: results, full: false),
              footer,
            ],
          );

        if (results[0].explorable == Explorable.review)
          return CustomScrollView(
            physics: Consts.physics,
            controller: scrollCtrl,
            slivers: [refreshControl, ReviewGridOld(items: results), footer],
          );

        return CustomScrollView(
          physics: Consts.physics,
          controller: scrollCtrl,
          slivers: [refreshControl, TileGrid(models: results), footer],
        );
      },
    );
  }
}

class _BirthdayFilter extends StatefulWidget {
  _BirthdayFilter({required this.value, required this.onChanged});

  final bool value;
  final void Function(bool) onChanged;

  @override
  State<_BirthdayFilter> createState() => _BirthdayFilterState();
}

class _BirthdayFilterState extends State<_BirthdayFilter> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didUpdateWidget(covariant _BirthdayFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) => TopBarIcon(
        icon: Icons.cake_outlined,
        tooltip: 'Birthday Filter',
        colour: _value ? Theme.of(context).colorScheme.primary : null,
        onTap: () {
          setState(() => _value = !_value);
          widget.onChanged(_value);
        },
      );
}

class ExploreActionButton extends StatelessWidget {
  const ExploreActionButton();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExploreController>(
      id: ExploreController.ID_BUTTON,
      builder: (ctrl) => ActionButton(
        tooltip: 'Types',
        icon: ctrl.type.icon,
        onTap: () => showSheet(
          context,
          DynamicGradientDragSheet(
            onTap: (i) => ctrl.type = Explorable.values[i],
            children: [
              for (int i = 0; i < Explorable.values.length; i++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Explorable.values[i].icon,
                      color: i != ctrl.type.index
                          ? Theme.of(context).colorScheme.onBackground
                          : Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      Convert.clarifyEnum(Explorable.values[i].name)!,
                      style: i != ctrl.type.index
                          ? Theme.of(context).textTheme.headline1
                          : Theme.of(context).textTheme.headline1?.copyWith(
                              color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
            ],
          ),
        ),
        onSwipe: (goRight) {
          if (goRight) {
            if (ctrl.type.index < Explorable.values.length - 1)
              ctrl.type = Explorable.values.elementAt(ctrl.type.index + 1);
            else
              ctrl.type = Explorable.values.elementAt(0);
          } else {
            if (ctrl.type.index > 0)
              ctrl.type = Explorable.values.elementAt(ctrl.type.index - 1);
            else
              ctrl.type = Explorable.values.last;
          }

          return ctrl.type.icon;
        },
      ),
    );
  }
}
