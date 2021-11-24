import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/controllers/explore_controller.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/utils/navigation.dart';
import 'package:otraku/constants/config.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/filterable.dart';
import 'package:otraku/utils/theming.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';

class SliverCollectionAppBar extends StatelessWidget {
  SliverCollectionAppBar(this.ctrlTag, this.canPop);

  final String ctrlTag;
  final bool canPop;

  @override
  Widget build(BuildContext context) {
    final leading = canPop
        ? AppBarIcon(
            tooltip: 'Close',
            icon: Ionicons.chevron_back_outline,
            onTap: () => Navigator.pop(context),
          )
        : const SizedBox(width: 10);

    return GetBuilder<CollectionController>(
      id: CollectionController.ID_HEAD,
      tag: ctrlTag,
      builder: (ctrl) {
        if (ctrl.isLoading || ctrl.isEmpty)
          return SliverTransparentAppBar([leading]);

        return SliverTransparentAppBar([
          leading,
          MediaSearchField(
            scrollToTop: () => ctrl.scrollUpTo(0),
            swipe: (offset) => ctrl.listIndex += offset,
            hint: ctrl.currentName,
            searchValue: ctrl.getFilterWithKey(Filterable.SEARCH) ?? '',
            search: (val) => ctrl.setFilterWithKey(
              Filterable.SEARCH,
              value: val,
              update: true,
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    ctrl.currentName,
                    style: Theme.of(context).textTheme.headline2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  ' ${ctrl.currentCount}',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ],
            ),
          ),
          AppBarIcon(
            tooltip: 'Random',
            icon: Ionicons.shuffle_outline,
            onTap: () {
              final entry = ctrl.random;
              Navigation().push(
                Navigation.mediaRoute,
                args: [entry.mediaId, entry.cover],
              );
            },
          ),
          _FilterIcon(ctrlTag),
        ]);
      },
    );
  }
}

class SliverExploreAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ExploreController>();
    return Obx(
      () => SliverTransparentAppBar(
        [
          const SizedBox(width: 10),
          MediaSearchField(
            scrollToTop: () => ctrl.scrollUpTo(0),
            swipe: (offset) {
              final index = ctrl.type.index + offset;
              if (index >= 0 && index < Explorable.values.length)
                ctrl.type = Explorable.values[index];
            },
            hint: Convert.clarifyEnum(describeEnum(ctrl.type))!,
            searchValue: ctrl.search,
            search: ctrl.type != Explorable.review
                ? (val) => ctrl.search = val
                : null,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(ctrl.type.icon,
                    color: Theme.of(context).colorScheme.onBackground),
                const SizedBox(width: 15),
                Flexible(
                  child: Text(
                    Convert.clarifyEnum(describeEnum(ctrl.type))!,
                    style: Theme.of(context).textTheme.headline2,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          if (ctrl.type == Explorable.anime || ctrl.type == Explorable.manga)
            _FilterIcon(null)
          else if (ctrl.type == Explorable.character ||
              ctrl.type == Explorable.staff)
            _BirthdayIcon(ctrl),
        ],
      ),
    );
  }
}

class MediaSearchField extends StatefulWidget {
  MediaSearchField({
    required this.scrollToTop,
    required this.swipe,
    required this.title,
    required this.hint,
    required this.searchValue,
    required this.search,
  });

  final Function() scrollToTop;
  final Function(int) swipe;
  final Widget title;
  final String hint;
  final String searchValue;
  final Function(String)? search;

  @override
  _MediaSearchFieldState createState() => _MediaSearchFieldState();
}

class _MediaSearchFieldState extends State<MediaSearchField> {
  late bool _empty;
  late bool _onSearch;
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.searchValue);
    _onSearch = widget.search != null && widget.searchValue != '';
    _empty = _ctrl.text.isEmpty;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!_onSearch) ...[
            Expanded(
              child: GestureDetector(
                child: widget.title,
                onTap: widget.scrollToTop,
                behavior: HitTestBehavior.opaque,
              ),
            ),
            if (widget.search != null)
              AppBarIcon(
                tooltip: 'Search',
                icon: Ionicons.search_outline,
                onTap: () => setState(() => _onSearch = true),
              ),
          ] else
            WillPopScope(
              onWillPop: () {
                setState(() => _onSearch = false);
                _ctrl.clear();
                _update('');
                return Future.value(false);
              },
              child: Expanded(
                child: Container(
                  height: 35,
                  padding: const EdgeInsets.only(right: 10),
                  child: TextField(
                    controller: _ctrl,
                    autofocus: true,
                    scrollPhysics: Config.PHYSICS,
                    cursorColor: Theme.of(context).colorScheme.secondary,
                    style: Theme.of(context).textTheme.headline6,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(30),
                    ],
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(left: 10),
                      hintText: widget.hint,
                      suffixIcon: _empty
                          ? IconButton(
                              tooltip: 'Hide',
                              constraints: const BoxConstraints(maxWidth: 40),
                              padding: const EdgeInsets.all(0),
                              icon:
                                  const Icon(Ionicons.chevron_forward_outline),
                              iconSize: Theming.ICON_SMALL,
                              splashColor: Colors.transparent,
                              color: Theme.of(context).colorScheme.primary,
                              onPressed: () =>
                                  setState(() => _onSearch = false),
                            )
                          : IconButton(
                              tooltip: 'Clear',
                              constraints: const BoxConstraints(maxWidth: 40),
                              padding: const EdgeInsets.all(0),
                              icon: const Icon(Icons.close_rounded),
                              iconSize: Theming.ICON_SMALL,
                              splashColor: Colors.transparent,
                              color: Theme.of(context).colorScheme.primary,
                              onPressed: () {
                                _ctrl.clear();
                                _update('');
                              },
                            ),
                    ),
                    onChanged: (text) => _update(text),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _update(String text) {
    widget.search!(text);
    if (_empty != text.isEmpty) setState(() => _empty = text.isEmpty);
  }
}

class _FilterIcon extends StatefulWidget {
  _FilterIcon(this.collectionTag);

  final String? collectionTag;

  @override
  _FilterIconState createState() => _FilterIconState();
}

class _FilterIconState extends State<_FilterIcon> {
  late Filterable _filterable;
  late bool _active;

  @override
  void initState() {
    super.initState();
    if (widget.collectionTag != null)
      _filterable = Get.find<CollectionController>(tag: widget.collectionTag);
    else
      _filterable = Get.find<ExploreController>();
    _active = _checkIfActive();
  }

  @override
  void didUpdateWidget(covariant _FilterIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    _active = _checkIfActive();
  }

  @override
  Widget build(BuildContext context) => AppBarIcon(
        tooltip: 'Filter',
        icon: Ionicons.funnel_outline,
        onTap: () => Navigation().push(
          Navigation.filtersRoute,
          args: [
            widget.collectionTag,
            (bool definitelyInactive) => definitelyInactive
                ? setState(() => _active = false)
                : setState(() => _active = _checkIfActive()),
          ],
        ),
        colour: _active ? Theme.of(context).colorScheme.secondary : null,
      );

  bool _checkIfActive() => _filterable.anyActiveFilterFrom(const [
        Filterable.ON_LIST,
        Filterable.COUNTRY,
        Filterable.STATUS_IN,
        Filterable.FORMAT_IN,
        Filterable.GENRE_IN,
        Filterable.GENRE_NOT_IN,
        Filterable.TAG_IN,
        Filterable.TAG_NOT_IN,
      ]);
}

class _BirthdayIcon extends StatefulWidget {
  _BirthdayIcon(this.ctrl);

  final ExploreController ctrl;

  @override
  State<_BirthdayIcon> createState() => _BirthdayIconState();
}

class _BirthdayIconState extends State<_BirthdayIcon> {
  late bool _active;

  @override
  void initState() {
    super.initState();
    _active = widget.ctrl.anyActiveFilterFrom([Filterable.IS_BIRTHDAY]);
  }

  @override
  Widget build(BuildContext context) => AppBarIcon(
        icon: Icons.cake_outlined,
        tooltip: 'Birthday Filter',
        colour: _active ? Theme.of(context).colorScheme.secondary : null,
        onTap: () {
          if (widget.ctrl.anyActiveFilterFrom([Filterable.IS_BIRTHDAY])) {
            widget.ctrl.setFilterWithKey(Filterable.IS_BIRTHDAY, update: true);
            setState(() => _active = false);
          } else {
            widget.ctrl.setFilterWithKey(
              Filterable.IS_BIRTHDAY,
              update: true,
              value: true,
            );
            setState(() => _active = true);
          }
        },
      );
}
