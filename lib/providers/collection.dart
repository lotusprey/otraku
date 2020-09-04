import 'package:otraku/enums/media_list_sort_enum.dart';
import 'package:otraku/models/list_entry_media_data.dart';
import 'package:otraku/models/tuple.dart';

abstract class Collection {
  MediaListSort get sort;

  set sort(MediaListSort value);

  //The name of this collection's type
  String get name;

  bool get isLoading;

  bool get isEmpty;

  Tuple<List<String>, List<List<ListEntryMediaData>>> lists({
    int listIndex = -1,
    String search,
  });

  //Fetch media list collection
  Future<void> fetchMediaListCollection();

  Future<void> removeFromList(int id);
}
