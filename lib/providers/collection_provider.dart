import 'package:otraku/enums/media_list_sort_enum.dart';
import 'package:otraku/models/entry_user_data.dart';
import 'package:otraku/models/media_entry.dart';
import 'package:otraku/providers/media_group_provider.dart';

//Manages the users collections of lists
abstract class CollectionProvider implements MediaGroupProvider {
  //The name of this collection's type
  String get collectionName;

  bool get isAnimeCollection;

  int get listIndex;

  set listIndex(int index);

  MediaListSort get sort;

  set sort(MediaListSort value);

  List<String> get names;

  List<MediaEntry> get entries;

  bool get isEmpty;

  void sortCollection();

  void sortList(int index);

  Future<bool> updateEntry(EntryUserData oldData, EntryUserData newData);
}
