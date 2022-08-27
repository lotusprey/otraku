import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/collection/collection_models.dart';
import 'package:otraku/filter/filter_providers.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/debounce.dart';
import 'package:otraku/widgets/fields/drop_down_field.dart';
import 'package:otraku/widgets/fields/search_field.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';

class SortDropDown<T extends Enum> extends StatelessWidget {
  SortDropDown(this.values, this.index, this.onChange);

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
  OrderDropDown(this.values, this.index, this.onChange);

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

class CountryDropDown extends StatelessWidget {
  CountryDropDown(this.value, this.onChanged);

  final String? value;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    final countries = <String, String?>{'All': null};
    for (final e in Convert.countryCodes.entries) countries[e.value] = e.key;

    return DropDownField<String?>(
      title: 'Country',
      value: value,
      items: countries,
      onChanged: onChanged,
    );
  }
}

class ListPresenceDropDown extends StatelessWidget {
  ListPresenceDropDown({required this.value, required this.onChanged});

  final bool? value;
  final void Function(bool?) onChanged;

  @override
  Widget build(BuildContext context) {
    return DropDownField<bool?>(
      title: 'List Filter',
      value: value,
      items: const {'Everything': null, 'On List': true, 'Not On List': false},
      onChanged: onChanged,
    );
  }
}

/// Openable search field that connects to [provider].
/// `null` state means that the field is closed.
class SearchFilterField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (!enabled)
      return Expanded(
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headline1,
        ),
      );

    final debounce = Debounce();

    return Consumer(
      builder: (context, ref, _) {
        final value = ref.watch(searchProvider(tag));

        return Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (value == null) ...[
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headline1,
                  ),
                ),
                TopBarIcon(
                  tooltip: 'Search',
                  icon: Ionicons.search_outline,
                  onTap: () =>
                      ref.read(searchProvider(tag).notifier).state = '',
                ),
              ] else
                Expanded(
                  child: SearchField(
                    value: value,
                    hint: title,
                    onChange: (val) => debounce.run(
                      () => ref.read(searchProvider(tag).notifier).state = val,
                    ),
                    onHide: () =>
                        ref.read(searchProvider(tag).notifier).state = null,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
