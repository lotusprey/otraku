import 'package:otraku/models/list_entry_tile_data.dart';
import 'package:otraku/models/tuple.dart';

abstract class Collection {
  String get name;

  bool get isLoaded;

  List<String> get names;

  List<List<ListEntryTileData>> get entries;

  Tuple<List<String>, List<List<ListEntryTileData>>> getData(
    int listIndex,
    String search,
  ) {
    if (listIndex == -1) {
      if (search == null) {
        return Tuple(names, entries);
      }

      List<List<ListEntryTileData>> currentEntries = [];
      List<String> currentNames = [];
      for (int i = 0; i < names.length; i++) {
        List<ListEntryTileData> sublist = [];
        for (ListEntryTileData entry in entries[i]) {
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

    List<ListEntryTileData> currentEntries = [];
    for (ListEntryTileData entry in entries[listIndex]) {
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

  //Fetch media list collection
  Future<void> fetchMediaListCollection(Map<String, dynamic> filters);
}
