import 'package:otraku/enums/media_list_sort_enum.dart';
import 'package:otraku/models/list_entry_media_data.dart';
import 'package:otraku/models/tuple.dart';

//Manages the users collections of lists
abstract class Collection {
  String get search;

  MediaListSort get sort;

  set sort(MediaListSort value);

  //The name of this collection's type
  String get collectionName;

  List<String> get names;

  bool get isLoading;

  bool get isEmpty;

  //Configure the list index and search filters
  void setFilters({listIndex, search});

  //Returns filtered lists
  Tuple<List<String>, List<List<ListEntryMediaData>>> lists();

  //Fetch media list collection
  Future<void> fetchMedia();
}
