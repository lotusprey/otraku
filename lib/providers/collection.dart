import 'package:otraku/models/list_entry.dart';
import 'package:otraku/models/tuple.dart';

abstract class Collection {
  String get name;

  bool get isLoaded;

  List<String> get names;

  List<List<ListEntry>> get entries;

  Tuple<List<String>, List<List<ListEntry>>> getData(
    int listIndex,
    String search,
  ) {
    if (listIndex == -1) {
      if (search == null) {
        return Tuple(names, entries);
      }

      List<List<ListEntry>> currentEntries = [];
      List<String> currentNames = [];
      for (int i = 0; i < names.length; i++) {
        List<ListEntry> sublist = [];
        for (ListEntry entry in entries[i]) {
          if (entry.title.toLowerCase().contains(search)) {
            sublist.add(entry);
          }
        }

        if (sublist.length > 0) {
          currentEntries.add(sublist);
          currentNames.add(names[i]);
        }
      }

      if (currentEntries.length == 0) {
        return null;
      }

      return Tuple(currentNames, currentEntries);
    }

    if (search == null) {
      return Tuple([names[listIndex]], [entries[listIndex]]);
    }

    List<ListEntry> currentEntries = [];
    for (ListEntry entry in entries[listIndex]) {
      if (entry.title.toLowerCase().contains(search)) {
        currentEntries.add(entry);
      }
    }

    if (currentEntries.length == 0) {
      return null;
    }

    return Tuple([names[listIndex]], [currentEntries]);
  }

  //Set isLoaded property to false in order to reload
  void unload();

  Future<void> fetchMediaListCollection(Map<String, dynamic> filters);
}
