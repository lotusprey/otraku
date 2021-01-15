import 'package:flutter/foundation.dart';
import 'package:otraku/helpers/enum_helper.dart';
import 'package:otraku/enums/list_sort.dart';
import 'package:otraku/enums/list_status.dart';
import 'package:otraku/models/anilist/media_list_data.dart';

class EntryList {
  final String name;
  final ListStatus status;
  final bool isCustomList;
  final String splitCompletedListFormat;
  final List<MediaListData> entries;

  EntryList._({
    @required this.name,
    @required this.isCustomList,
    @required this.entries,
    this.status,
    this.splitCompletedListFormat,
  });

  factory EntryList(Map<String, dynamic> map, bool splitCompleted) {
    List<MediaListData> entries = [];
    for (final e in map['entries']) entries.add(MediaListData(e));

    return EntryList._(
      name: map['name'],
      isCustomList: map['isCustomList'],
      status: !map['isCustomList']
          ? EnumHelper.stringToEnum(map['status'], ListStatus.values)
          : null,
      splitCompletedListFormat:
          splitCompleted && !map['isCustomList'] && map['status'] == 'COMPLETED'
              ? map['entries'][0]['media']['format']
              : null,
      entries: entries,
    );
  }

  void sort(final ListSort sorting) {
    int Function(MediaListData, MediaListData) fn;

    switch (sorting) {
      case ListSort.TITLE:
        fn = (a, b) => a.title.compareTo(b.title);
        break;
      case ListSort.TITLE_DESC:
        fn = (a, b) => b.title.compareTo(a.title);
        break;
      case ListSort.SCORE:
        fn = (a, b) {
          int comparison = a.score.compareTo(b.score);
          if (comparison != 0) return comparison;
          return a.title.compareTo(b.title);
        };
        break;
      case ListSort.SCORE_DESC:
        fn = (a, b) {
          int comparison = b.score.compareTo(a.score);
          if (comparison != 0) return comparison;
          return a.title.compareTo(b.title);
        };
        break;
      case ListSort.UPDATED_AT:
        fn = (a, b) {
          int comparison = a.updatedAt.compareTo(b.updatedAt);
          if (comparison != 0) return comparison;
          return a.title.compareTo(b.title);
        };
        break;
      case ListSort.UPDATED_AT_DESC:
        fn = (a, b) {
          int comparison = b.updatedAt.compareTo(a.updatedAt);
          if (comparison != 0) return comparison;
          return a.title.compareTo(b.title);
        };
        break;
      case ListSort.CREATED_AT:
        fn = (a, b) {
          int comparison = a.createdAt.compareTo(b.createdAt);
          if (comparison != 0) return comparison;
          return a.title.compareTo(b.title);
        };
        break;
      case ListSort.CREATED_AT_DESC:
        fn = (a, b) {
          int comparison = b.createdAt.compareTo(a.createdAt);
          if (comparison != 0) return comparison;
          return a.title.compareTo(b.title);
        };
        break;
      case ListSort.PROGRESS:
        fn = (a, b) {
          int comparison = a.progress.compareTo(b.progress);
          if (comparison != 0) return comparison;
          return a.title.compareTo(b.title);
        };
        break;
      case ListSort.PROGRESS_DESC:
        fn = (a, b) {
          int comparison = b.progress.compareTo(a.progress);
          if (comparison != 0) return comparison;
          return a.title.compareTo(b.title);
        };
        break;
      case ListSort.REPEAT:
        fn = (a, b) {
          int comparison = a.repeat.compareTo(b.repeat);
          if (comparison != 0) return comparison;
          return a.title.compareTo(b.title);
        };
        break;
      case ListSort.REPEAT_DESC:
        fn = (a, b) {
          int comparison = b.repeat.compareTo(a.repeat);
          if (comparison != 0) return comparison;
          return a.title.compareTo(b.title);
        };
        break;
      default:
        break;
    }

    entries.sort(fn);
  }
}
