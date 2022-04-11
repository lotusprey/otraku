import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/collection_controller.dart';
import 'package:otraku/controllers/explore_controller.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/models/filter_model.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/views/filter_view.dart';
import 'package:otraku/widgets/fields/search_field.dart';
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
          return TranslucentSliverAppBar(children: [leading]);

        return TranslucentSliverAppBar(
          children: [
            leading,
            _MediaSearchField(
              value: ctrl.search,
              title: ctrl.currentName,
              onChanged: (val) => ctrl.search = val,
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
            MediaFilterIcon(ctrl.filters),
          ],
        );
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
        return TranslucentSliverAppBar(
          children: [
            const SizedBox(width: 10),
            _MediaSearchField(
              value: ctrl.search,
              title: Convert.clarifyEnum(type.name)!,
              onChanged:
                  type != Explorable.review ? (val) => ctrl.search = val : null,
            ),
            if (type == Explorable.anime || type == Explorable.manga)
              MediaFilterIcon(ctrl.filters)
            else if (type == Explorable.character || type == Explorable.staff)
              BirthdayFilterIcon(ctrl)
            else
              const SizedBox(width: 10),
          ],
        );
      },
    );
  }
}

class _MediaSearchField extends StatefulWidget {
  _MediaSearchField({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String? value;

  /// If [null], search mode cannot be turned on; [value] & [hint] are ignored.
  final void Function(String?)? onChanged;

  @override
  _MediaSearchFieldState createState() => _MediaSearchFieldState();
}

class _MediaSearchFieldState extends State<_MediaSearchField> {
  String? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didUpdateWidget(covariant _MediaSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_value == null) ...[
            Expanded(
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.headline1,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (widget.onChanged != null)
              AppBarIcon(
                tooltip: 'Search',
                icon: Ionicons.search_outline,
                onTap: () => widget.onChanged?.call(''),
              ),
          ] else
            Expanded(
              child: SearchField(
                value: _value!,
                hint: widget.title,
                onChange: (val) => widget.onChanged?.call(val),
                onHide: () => widget.onChanged?.call(null),
              ),
            ),
        ],
      ),
    );
  }
}

class MediaFilterIcon extends StatefulWidget {
  MediaFilterIcon(this.filters);

  final FilterModel filters;

  @override
  _MediaFilterIconState createState() => _MediaFilterIconState();
}

class _MediaFilterIconState extends State<MediaFilterIcon> {
  late bool _active;

  @override
  void initState() {
    super.initState();
    _active = _isActive();
  }

  @override
  void didUpdateWidget(covariant MediaFilterIcon oldWidget) {
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
        colour: _active ? Theme.of(context).colorScheme.primary : null,
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

class BirthdayFilterIcon extends StatefulWidget {
  BirthdayFilterIcon(this.ctrl);

  final ExploreController ctrl;

  @override
  State<BirthdayFilterIcon> createState() => _BirthdayFilterIconState();
}

class _BirthdayFilterIconState extends State<BirthdayFilterIcon> {
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
        colour: _active ? Theme.of(context).colorScheme.primary : null,
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
