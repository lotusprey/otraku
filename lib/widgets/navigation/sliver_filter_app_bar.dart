import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/controllers/explore_controller.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/models/filter_model.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/views/filter_view.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

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
            hint: ctrl.currentName,
            value: ctrl.search,
            isSearchActive: ctrl.searchMode,
            onSearch: (val) {
              if (val == null) {
                ctrl.searchMode = !ctrl.searchMode;
                return;
              }

              ctrl.search = val;
            },
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    ctrl.currentName,
                    style: Theme.of(context).textTheme.headline1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  ' ${ctrl.currentCount}',
                  style: Theme.of(context).textTheme.headline3,
                ),
              ],
            ),
          ),
          AppBarIcon(
            tooltip: 'Random',
            icon: Ionicons.shuffle_outline,
            onTap: () {
              final entry = ctrl.random;
              Navigator.pushNamed(
                context,
                RouteArg.media,
                arguments: RouteArg(id: entry.mediaId, info: entry.cover),
              );
            },
          ),
          _FilterIcon(ctrl.filters),
        ]);
      },
    );
  }
}

class SliverExploreAppBar extends StatelessWidget {
  const SliverExploreAppBar();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExploreController>(
      id: ExploreController.ID_HEAD,
      builder: (ctrl) {
        final type = ctrl.type;
        return SliverTransparentAppBar(
          [
            const SizedBox(width: 10),
            MediaSearchField(
              hint: Convert.clarifyEnum(type.name)!,
              value: ctrl.search,
              onSearch: type != Explorable.review
                  ? (val) {
                      if (val == null) {
                        ctrl.searchMode = !ctrl.searchMode;
                        return;
                      }

                      ctrl.search = val;
                    }
                  : null,
              isSearchActive: ctrl.searchMode,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    type.icon,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  const SizedBox(width: 15),
                  Flexible(
                    child: Text(
                      Convert.clarifyEnum(type.name)!,
                      style: Theme.of(context).textTheme.headline1,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            if (type == Explorable.anime || type == Explorable.manga)
              _FilterIcon(ctrl.filters)
            else if (type == Explorable.character || type == Explorable.staff)
              _BirthdayIcon(ctrl),
          ],
        );
      },
    );
  }
}

class MediaSearchField extends StatefulWidget {
  MediaSearchField({
    required this.title,
    required this.hint,
    required this.value,
    required this.isSearchActive,
    required this.onSearch,
  });

  final Widget title;
  final String hint;
  final String value;
  final bool isSearchActive;

  /// If [null], search mode cannot be turned on. When [null] is
  /// passed to this, the search mode must be toggled by the parent.
  final void Function(String?)? onSearch;

  @override
  _MediaSearchFieldState createState() => _MediaSearchFieldState();
}

class _MediaSearchFieldState extends State<MediaSearchField> {
  late final TextEditingController _ctrl;

  /// This is compared with wether the [_ctrl]'s text is empty, so changes
  /// from empty to not empty and vice versa can update the clear/hide icons.
  late bool _empty;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
    _empty = _ctrl.text.isEmpty;
  }

  @override
  void didUpdateWidget(covariant MediaSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_ctrl.text != widget.value) {
      _ctrl.text = widget.value;
      _empty = _ctrl.text.isEmpty;
    }
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
          if (!widget.isSearchActive) ...[
            Expanded(child: widget.title),
            if (widget.onSearch != null)
              AppBarIcon(
                tooltip: 'Search',
                icon: Ionicons.search_outline,
                onTap: () => widget.onSearch?.call(null),
              ),
          ] else
            Expanded(
              child: Container(
                height: 35,
                padding: const EdgeInsets.only(right: 10),
                child: TextField(
                  controller: _ctrl,
                  autofocus: true,
                  scrollPhysics: Consts.PHYSICS,
                  cursorColor: Theme.of(context).colorScheme.secondary,
                  style: Theme.of(context).textTheme.bodyText2,
                  inputFormatters: [LengthLimitingTextInputFormatter(30)],
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 10),
                    hintText: widget.hint,
                    suffixIcon: _empty
                        ? IconButton(
                            tooltip: 'Hide',
                            constraints: const BoxConstraints(maxWidth: 40),
                            padding: const EdgeInsets.all(0),
                            icon: const Icon(Ionicons.chevron_forward_outline),
                            iconSize: Consts.ICON_SMALL,
                            splashColor: Colors.transparent,
                            color: Theme.of(context).colorScheme.primary,
                            onPressed: () => widget.onSearch?.call(null),
                          )
                        : IconButton(
                            tooltip: 'Clear',
                            constraints: const BoxConstraints(maxWidth: 40),
                            padding: const EdgeInsets.all(0),
                            icon: const Icon(Icons.close_rounded),
                            iconSize: Consts.ICON_SMALL,
                            splashColor: Colors.transparent,
                            color: Theme.of(context).colorScheme.primary,
                            onPressed: () {
                              _ctrl.clear();
                              widget.onSearch?.call('');
                              setState(() => _empty = true);
                            },
                          ),
                  ),
                  onChanged: (text) {
                    widget.onSearch?.call(text);
                    if (_empty != _ctrl.text.isEmpty)
                      setState(() => _empty = _ctrl.text.isEmpty);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterIcon extends StatefulWidget {
  _FilterIcon(this.filters);

  final FilterModel filters;

  @override
  _FilterIconState createState() => _FilterIconState();
}

class _FilterIconState extends State<_FilterIcon> {
  late bool _active;

  @override
  void initState() {
    super.initState();
    _active = _isActive();
  }

  @override
  void didUpdateWidget(covariant _FilterIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    _active = _isActive();
  }

  @override
  Widget build(BuildContext context) => AppBarIcon(
        tooltip: 'Filter',
        icon: Ionicons.funnel_outline,
        onTap: () => showSheet(context, FilterView(widget.filters)).then((_) {
          if (_active != _isActive()) setState(() => _active = !_active);
        }),
        colour: _active ? Theme.of(context).colorScheme.secondary : null,
      );

  bool _isActive() {
    final f = widget.filters;
    if (f.country != null ||
        f.statuses.isNotEmpty ||
        f.formats.isNotEmpty ||
        f.genreIn.isNotEmpty ||
        f.genreNotIn.isNotEmpty ||
        f.tagIn.isNotEmpty ||
        f.tagNotIn.isNotEmpty) return true;

    if (f is ExploreFilterModel && f.onList != null) return true;

    return false;
  }
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
    _active = widget.ctrl.isBirthday;
  }

  @override
  Widget build(BuildContext context) => AppBarIcon(
        icon: Icons.cake_outlined,
        tooltip: 'Birthday Filter',
        colour: _active ? Theme.of(context).colorScheme.secondary : null,
        onTap: () {
          if (widget.ctrl.isBirthday) {
            widget.ctrl.isBirthday = false;
            setState(() => _active = false);
          } else {
            widget.ctrl.isBirthday = true;
            setState(() => _active = true);
          }
        },
      );
}
