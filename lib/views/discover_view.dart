import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/discover_controller.dart';
import 'package:otraku/constants/discover_type.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/filter/filter_view.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/review/review_grid.dart';
import 'package:otraku/widgets/grids/title_grid.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/grids/tile_grid.dart';
import 'package:otraku/filter/filter_tools.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class DiscoverView extends StatelessWidget {
  DiscoverView(this.scrollCtrl);

  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DiscoverController>(
      builder: (ctrl) => PageLayout(
        floatingBar: FloatingBar(
          scrollCtrl: scrollCtrl,
          children: const [DiscoverActionButton()],
        ),
        topBar: TopBar(
          canPop: false,
          items: [
            GetBuilder<DiscoverController>(
              id: DiscoverController.ID_HEAD,
              builder: (ctrl) => MediaSearchField(
                value: ctrl.search,
                title: Convert.clarifyEnum(ctrl.type.name)!,
                onChanged: ctrl.type != DiscoverType.review
                    ? (val) => ctrl.search = val
                    : null,
              ),
            ),
            GetBuilder<DiscoverController>(
              id: DiscoverController.ID_HEAD,
              builder: (ctrl) {
                if (ctrl.type == DiscoverType.anime ||
                    ctrl.type == DiscoverType.manga)
                  return TopBarIcon(
                    tooltip: 'Filter',
                    icon: Ionicons.funnel_outline,
                    onTap: () => showSheet(
                      context,
                      DiscoverFilterView(
                        filter: ctrl.filter,
                        onChanged: (filter) => ctrl.filter = filter,
                      ),
                    ),
                  );

                if (ctrl.type == DiscoverType.character ||
                    ctrl.type == DiscoverType.staff)
                  return _BirthdayFilter(
                    value: ctrl.isBirthday,
                    onChanged: (val) => ctrl.isBirthday = val,
                  );

                return const SizedBox(width: 10);
              },
            ),
          ],
        ),
        child: _DiscoverGrid(ctrl, scrollCtrl),
      ),
    );
  }
}

class _DiscoverGrid extends StatelessWidget {
  _DiscoverGrid(this.ctrl, this.scrollCtrl);

  final DiscoverController ctrl;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final refreshControl = SliverRefreshControl(
      onRefresh: ctrl.fetch,
      canRefresh: () => !ctrl.isLoading,
    );

    return GetBuilder<DiscoverController>(
      id: DiscoverController.ID_BODY,
      builder: (ctrl) {
        if (ctrl.isLoading) return const Center(child: Loader());

        final results = ctrl.results;
        if (results.isEmpty) return const Center(child: Text('No results'));

        final footer = SliverFooter(loading: ctrl.hasNextPage);

        if (results[0].discoverType == DiscoverType.studio)
          return CustomScrollView(
            physics: Consts.physics,
            controller: scrollCtrl,
            slivers: [refreshControl, TitleGrid(results), footer],
          );

        if (results[0].discoverType == DiscoverType.user)
          return CustomScrollView(
            physics: Consts.physics,
            controller: scrollCtrl,
            slivers: [
              refreshControl,
              TileGrid(models: results, full: false),
              footer,
            ],
          );

        if (results[0].discoverType == DiscoverType.review)
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

class DiscoverActionButton extends StatelessWidget {
  const DiscoverActionButton();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DiscoverController>(
      id: DiscoverController.ID_BUTTON,
      builder: (ctrl) => ActionButton(
        tooltip: 'Types',
        icon: ctrl.type.icon,
        onTap: () => showSheet(
          context,
          DynamicGradientDragSheet(
            onTap: (i) => ctrl.type = DiscoverType.values[i],
            children: [
              for (int i = 0; i < DiscoverType.values.length; i++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      DiscoverType.values[i].icon,
                      color: i != ctrl.type.index
                          ? Theme.of(context).colorScheme.onBackground
                          : Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      Convert.clarifyEnum(DiscoverType.values[i].name)!,
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
            if (ctrl.type.index < DiscoverType.values.length - 1)
              ctrl.type = DiscoverType.values.elementAt(ctrl.type.index + 1);
            else
              ctrl.type = DiscoverType.values.elementAt(0);
          } else {
            if (ctrl.type.index > 0)
              ctrl.type = DiscoverType.values.elementAt(ctrl.type.index - 1);
            else
              ctrl.type = DiscoverType.values.last;
          }

          return ctrl.type.icon;
        },
      ),
    );
  }
}
