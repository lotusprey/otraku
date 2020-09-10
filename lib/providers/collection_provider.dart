import 'package:otraku/enums/media_list_sort_enum.dart';
import 'package:otraku/models/list_entry_media.dart';
import 'package:otraku/providers/media_group_provider.dart';

//Manages the users collections of lists
abstract class CollectionProvider implements MediaGroupProvider {
  int get listIndex;

  set listIndex(int index);

  MediaListSort get sort;

  set sort(MediaListSort value);

  //The name of this collection's type
  String get collectionName;

  bool get isAnimeCollection;

  List<String> get names;

  List<ListEntryMedia> get entries;

  bool get isEmpty;

  void sortCollection();

  void sortList(int index);
}
