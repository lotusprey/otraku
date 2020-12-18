import 'package:otraku/enums/list_sort_enum.dart';
import 'package:otraku/enums/media_list_status_enum.dart';
import 'package:otraku/controllers/filterable.dart';
import 'package:otraku/models/entry_list.dart';
import 'package:otraku/models/page_data/edit_entry.dart';
import 'package:otraku/models/sample_data/media_entry.dart';

class Collection implements Filterable {
  final Function updateHandle;
  final Function fetchHandle;
  final int userId;
  final bool ofAnime;
  final bool completedListIsSplit;
  final String scoreFormat;
  final List<EntryList> lists;
  final Map<String, dynamic> _filters = {
    Filterable.SEARCH: null,
    Filterable.SORT: null,
  };
  int _listIndex = 0;

  Collection({
    this.updateHandle,
    this.fetchHandle,
    this.userId,
    this.ofAnime,
    this.completedListIsSplit,
    this.scoreFormat,
    this.lists,
    sort,
  }) {
    _filters[Filterable.SORT] = sort;
    _sortLists(lists, sort);
  }

  int get listIndex => _listIndex;

  set listIndex(int value) {
    if (value < 0 || value >= lists.length || value == _listIndex) return;
    _listIndex = value;
    updateHandle();
  }

  @override
  dynamic getFilterWithKey(String key) => _filters[key];

  @override
  void setFilterWithKey(String key, {dynamic value, bool update = false}) {
    if (value == null ||
        (value is List && value.isEmpty) ||
        (value is String && value.trim().isEmpty)) {
      _filters.remove(key);
    } else {
      _filters[key] = value;
    }

    if (update) updateHandle();
  }

  @override
  void clearAllFilters({bool update = true}) => clearFiltersWithKeys([
        Filterable.STATUS_IN,
        Filterable.STATUS_NOT_IN,
        Filterable.FORMAT_IN,
        Filterable.FORMAT_NOT_IN,
        Filterable.GENRE_IN,
        Filterable.GENRE_NOT_IN,
      ], update: update);

  @override
  void clearFiltersWithKeys(List<String> keys, {bool update = true}) {
    for (final key in keys) {
      _filters.remove(key);
    }

    if (update) updateHandle();
  }

  @override
  bool anyActiveFilterFrom(List<String> keys) {
    return false;
  }

  List<String> get listNames {
    List<String> names = [];
    for (final list in lists) names.add(list.name);
    return names;
  }

  List<int> get listEntryCounts {
    List<int> counts = [];
    for (final list in lists) counts.add(list.entries.length);
    return counts;
  }

  String get currentListName => lists[_listIndex].name;

  int get currentEntryCount => lists[_listIndex].entries.length;

  int get totalEntryCount {
    int count = 0;
    for (final list in lists)
      if (list.status != null) count += list.entries.length;
    return count;
  }

  List<MediaEntry> get entries {
    final search = (_filters[Filterable.SEARCH] as String)?.toLowerCase();
    final formatIn = _filters[Filterable.FORMAT_IN];
    final formatNotIn = _filters[Filterable.FORMAT_NOT_IN];
    final statusIn = _filters[Filterable.STATUS_IN];
    final statusNotIn = _filters[Filterable.STATUS_NOT_IN];

    final list = lists[_listIndex];
    final List<MediaEntry> entries = [];

    for (final entry in list.entries) {
      if (search != null && !entry.title.toLowerCase().contains(search))
        continue;

      if (formatIn != null) {
        bool isIn = false;
        for (final format in formatIn)
          if (entry.format == format) {
            isIn = true;
            break;
          }
        if (!isIn) continue;
      }

      if (formatNotIn != null) {
        bool isIn = false;
        for (final format in formatNotIn)
          if (entry.format == format) {
            isIn = true;
            break;
          }
        if (isIn) continue;
      }

      if (statusIn != null) {
        bool isIn = false;
        for (final status in statusIn)
          if (entry.status == status) {
            isIn = true;
            break;
          }
        if (!isIn) continue;
      }

      if (statusNotIn != null) {
        bool isIn = false;
        for (final status in statusNotIn)
          if (entry.status == status) {
            isIn = true;
            break;
          }
        if (isIn) continue;
      }

      entries.add(entry);
    }

    return entries;
  }

  void updateEntry(
    EditEntry original,
    EditEntry changed,
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
        listIndex = _listIndex - 1;
        lists.removeAt(i--);
      }
    }

    _sortLists(updatedLists, _filters[Filterable.SORT]);

    updateHandle();
  }

  void removeEntry(EditEntry entry, {bool cleanUp = true}) {
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
          listIndex = _listIndex - 1;
          lists.removeAt(i--);
        }
      }
      updateHandle();
    }
  }

  void sort() {
    _sortLists(lists, _filters[Filterable.SORT]);
    updateHandle();
  }

  static void _sortLists(List<EntryList> entryLists, ListSort sorting) {
    switch (sorting) {
      case ListSort.TITLE:
        for (final list in entryLists)
          list.entries.sort((a, b) => a.title.compareTo(b.title));
        break;
      case ListSort.TITLE_DESC:
        for (final list in entryLists)
          list.entries.sort((a, b) => b.title.compareTo(a.title));
        break;
      case ListSort.SCORE:
        for (final list in entryLists)
          list.entries.sort((a, b) {
            int comparison = a.score.compareTo(b.score);
            if (comparison != 0) return comparison;
            return a.title.compareTo(b.title);
          });
        break;
      case ListSort.SCORE_DESC:
        for (final list in entryLists)
          list.entries.sort((a, b) {
            int comparison = b.score.compareTo(a.score);
            if (comparison != 0) return comparison;
            return a.title.compareTo(b.title);
          });
        break;
      case ListSort.UPDATED_AT:
        for (final list in entryLists)
          list.entries.sort((a, b) {
            int comparison = a.updatedAt.compareTo(b.updatedAt);
            if (comparison != 0) return comparison;
            return a.title.compareTo(b.title);
          });
        break;
      case ListSort.UPDATED_AT_DESC:
        for (final list in entryLists)
          list.entries.sort((a, b) {
            int comparison = b.updatedAt.compareTo(a.updatedAt);
            if (comparison != 0) return comparison;
            return a.title.compareTo(b.title);
          });
        break;
      case ListSort.CREATED_AT:
        for (final list in entryLists)
          list.entries.sort((a, b) {
            int comparison = a.createdAt.compareTo(b.createdAt);
            if (comparison != 0) return comparison;
            return a.title.compareTo(b.title);
          });
        break;
      case ListSort.CREATED_AT_DESC:
        for (final list in entryLists)
          list.entries.sort((a, b) {
            int comparison = b.createdAt.compareTo(a.createdAt);
            if (comparison != 0) return comparison;
            return a.title.compareTo(b.title);
          });
        break;
      case ListSort.PROGRESS:
        for (final list in entryLists)
          list.entries.sort((a, b) {
            int comparison = a.progress.compareTo(b.progress);
            if (comparison != 0) return comparison;
            return a.title.compareTo(b.title);
          });
        break;
      case ListSort.PROGRESS_DESC:
        for (final list in entryLists)
          list.entries.sort((a, b) {
            int comparison = b.progress.compareTo(a.progress);
            if (comparison != 0) return comparison;
            return a.title.compareTo(b.title);
          });
        break;
      case ListSort.REPEAT:
        for (final list in entryLists)
          list.entries.sort((a, b) {
            int comparison = a.repeat.compareTo(b.repeat);
            if (comparison != 0) return comparison;
            return a.title.compareTo(b.title);
          });
        break;
      case ListSort.REPEAT_DESC:
        for (final list in entryLists)
          list.entries.sort((a, b) {
            int comparison = b.repeat.compareTo(a.repeat);
            if (comparison != 0) return comparison;
            return a.title.compareTo(b.title);
          });
        break;
      default:
        break;
    }
  }
}
