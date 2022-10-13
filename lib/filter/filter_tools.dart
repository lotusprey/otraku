import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/collection/collection_models.dart';
import 'package:otraku/filter/filter_providers.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/widgets/fields/drop_down_field.dart';
import 'package:otraku/widgets/fields/search_field.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';

class SortDropDown<T extends Enum> extends StatelessWidget {
  const SortDropDown(this.values, this.index, this.onChange);

  final List<T> values;
  final int Function() index;
  final void Function(T) onChange;

  @override
  Widget build(BuildContext context) {
    final items = <String, int>{};
    for (int i = 0; i < values.length; i += 2) {
      final key = Convert.clarifyEnum(values[i].name)!;
      items[key] = i ~/ 2;
    }

    return DropDownField<int>(
      title: 'Sort',
      value: index() ~/ 2,
      items: items,
      onChanged: (val) {
        int i = val * 2;
        if (index() % 2 != 0) i++;
        onChange(values[i]);
      },
    );
  }
}

class OrderDropDown<T extends Enum> extends StatelessWidget {
  const OrderDropDown(this.values, this.index, this.onChange);

  final List<T> values;
  final int Function() index;
  final void Function(T) onChange;

  @override
  Widget build(BuildContext context) {
    return DropDownField<bool>(
      title: 'Order',
      value: index() % 2 == 0,
      items: const {'Ascending': true, 'Descending': false},
      onChanged: (val) {
        int i = index();
        if (!val && i % 2 == 0) {
          i++;
        } else if (val && i % 2 != 0) {
          i--;
        }
        onChange(values[i]);
      },
    );
  }
}

/// After [_delay] time has passed, since the last [run] call, call [callback].
/// E.g. do a search query after the user stops typing.
class _Debounce {
  static const _delay = Duration(milliseconds: 600);

  Timer? _timer;

  void cancel() => _timer?.cancel();

  void run(void Function() callback) {
    _timer?.cancel();
    _timer = Timer(_delay, callback);
  }
}

/// Openable search field that connects to a collection or the discover tab.
class SearchFilterField extends StatefulWidget {
  const SearchFilterField({
    required this.title,
    this.enabled = true,
    this.tag,
  });

  final String title;

  /// `null` would mean this is responsible for
  /// the discover tab and not for a collection.
  final CollectionTag? tag;

  /// The discover tab may want to disable the
  /// search option for certain [DiscoverType] modes.
  final bool enabled;

  @override
  State<SearchFilterField> createState() => _SearchFilterFieldState();
}

class _SearchFilterFieldState extends State<SearchFilterField> {
  final _debounce = _Debounce();

  @override
  void dispose() {
    _debounce.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return Expanded(
        child: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headline1,
        ),
      );
    }

    return Consumer(
      builder: (context, ref, _) {
        ref.listen<String?>(
          searchProvider(widget.tag),
          (_, s) {
            if (s == null) _debounce.cancel();
          },
        );

        final value = ref.watch(searchProvider(widget.tag));

        return Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (value == null) ...[
                Expanded(
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headline1,
                  ),
                ),
                TopBarIcon(
                  tooltip: 'Search',
                  icon: Ionicons.search_outline,
                  onTap: () =>
                      ref.read(searchProvider(widget.tag).notifier).state = '',
                ),
              ] else
                Expanded(
                  child: SearchField(
                    value: value,
                    hint: widget.title,
                    onChange: (val) {
                      if (val.isEmpty) {
                        ref.read(searchProvider(widget.tag).notifier).state =
                            '';
                        return;
                      }

                      _debounce.run(
                        () {
                          ref.read(searchProvider(widget.tag).notifier).state =
                              val;
                        },
                      );
                    },
                    onHide: () => ref
                        .read(searchProvider(widget.tag).notifier)
                        .state = null,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
