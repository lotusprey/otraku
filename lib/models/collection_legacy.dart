import 'package:otraku/enums/media_list_status_enum.dart';
import 'package:otraku/models/entry_list.dart';
import 'package:otraku/models/page_data/entry_data.dart';
import 'package:otraku/models/sample_data/media_entry.dart';

class Collection {
  final Function updateHandle;
  final Function fetchHandle;
  final bool completedListIsSplit;
  final List<EntryList> lists;
  int _listIndex = 0;

  Collection({
    this.updateHandle,
    this.fetchHandle,
    this.completedListIsSplit,
    this.lists,
  });

  int get listIndex => _listIndex;

  void updateEntry(
    EntryData original,
    EntryData changed,
    MediaEntry entry,
    List<String> newCustomLists,
  ) {
    removeEntry(original, cleanUp: false);

    List<EntryList> updatedLists = [];

    if (!changed.hiddenFromStatusLists) {
      for (final list in lists) {
        if (completedListIsSplit &&
            changed.status == MediaListStatus.COMPLETED) {
          if (list.splitCompletedListFormat == entry.format) {
            list.entries.add(entry);
            updatedLists.add(list);
            break;
          }
        } else {
          if (!list.isCustomList && list.status == changed.status) {
            list.entries.add(entry);
            updatedLists.add(list);
            break;
          }
        }
      }

      if (updatedLists.length == 0) {
        fetchHandle();
        return;
      }
    }

    for (final list in lists) {
      if (list.isCustomList) {
        for (int i = 0; i < newCustomLists.length; i++) {
          if (list.name.toLowerCase() == newCustomLists[i].toLowerCase()) {
            list.entries.add(entry);
            updatedLists.add(list);
            newCustomLists.removeAt(i--);
            break;
          }
        }
      }
    }

    if (newCustomLists.length > 0) {
      fetchHandle();
      return;
    }

    for (int i = 0; i < lists.length; i++) {
      if (lists[i].entries.length == 0) {
        // listIndex = _listIndex - 1;
        _listIndex--;
        lists.removeAt(i--);
      }
    }

    // _sortLists(updatedLists, _filters[Filterable.SORT]);

    updateHandle();
  }

  void removeEntry(EntryData entry, {bool cleanUp = true}) {
    List<String> customLists = [];
    for (final tuple in entry.customLists)
      if (tuple.item2) customLists.add(tuple.item1.toLowerCase());

    for (final list in lists) {
      if (!entry.hiddenFromStatusLists && entry.status == list.status) {
        for (int i = 0; i < list.entries.length; i++) {
          if (entry.mediaId == list.entries[i].mediaId) {
            list.entries.removeAt(i);
            break;
          }
        }
      } else if (list.isCustomList &&
          customLists.contains(list.name.toLowerCase())) {
        for (int i = 0; i < list.entries.length; i++) {
          if (entry.mediaId == list.entries[i].mediaId) {
            list.entries.removeAt(i);
            break;
          }
        }
      }
    }

    if (cleanUp) {
      for (int i = 0; i < lists.length; i++) {
        if (lists[i].entries.length == 0) {
          // listIndex = _listIndex - 1;
          _listIndex--;
          lists.removeAt(i--);
        }
      }
      updateHandle();
    }
  }
}
