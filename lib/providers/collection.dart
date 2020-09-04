import 'package:otraku/enums/media_list_sort_enum.dart';
import 'package:otraku/models/list_entry_media_data.dart';
import 'package:otraku/models/tuple.dart';

abstract class Collection {
  MediaListSort get sort;

  set sort(MediaListSort value);

  //The name of this collection's type
  String get collectionName;

  List<String> get names;

  bool get isLoading;

  bool get isEmpty;

  String get search;

  //Configure the list index and search filters
  void setFilters({listIndex, search});

  //Returns filtered lists
  Tuple<List<String>, List<List<ListEntryMediaData>>> lists();

  //Fetch media list collection
  Future<void> fetchMediaListCollection();

  Future<void> removeFromList(int id);
}
