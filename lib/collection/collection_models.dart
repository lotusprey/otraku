import 'package:otraku/media/media_constants.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/settings.dart';

/// Used as an argument for a [collectionProvider] `family` instance.
class CollectionTag {
  CollectionTag(this.userId, this.ofAnime);

  final int userId;
  final bool ofAnime;

  @override
  int get hashCode => '$userId$ofAnime'.hashCode;

  @override
  bool operator ==(Object other) => hashCode == other.hashCode;
}

class EntryList {
  EntryList._({
    required this.name,
    required this.entries,
    required this.status,
    required this.splitCompletedListFormat,
  });

  factory EntryList(Map<String, dynamic> map, bool splitCompleted) {
    final status = !map['isCustomList'] && map['status'] != null
        ? EntryStatus.values.byName(map['status'])
        : null;

    return EntryList._(
      name: map['name'],
      status: status,
      splitCompletedListFormat:
          splitCompleted && status == EntryStatus.COMPLETED
              ? map['entries'][0]['media']['format']
              : null,
      entries: (map['entries'] as List<dynamic>).map((e) => Entry(e)).toList(),
    );
  }

  final String name;
  final List<Entry> entries;

  /// The [EntryStatus] of the [entries] in this list.
  /// If `null`, this is a custom list.
  final EntryStatus? status;

  /// If the user's "completed" list is split by format and this is one of the
  /// resulting lists, this holds the corresponding [AnimeFormat] or
  /// [MangaFormat]. Parsing the `String` is unnecessary for now.
  /// The value is `null`, if the list doesn't fulfill the
  /// aforementioned conditions.
  final String? splitCompletedListFormat;

  void removeByMediaId(int id) {
    for (int i = 0; i < entries.length; i++) {
      if (id == entries[i].mediaId) {
        entries.removeAt(i);
        return;
      }
    }
  }

  void insertSorted(Entry item, EntrySort s) {
    final compare = _compareFn(s);
    for (int i = 0; i < entries.length; i++) {
      if (compare(item, entries[i]) <= 0) {
        entries.insert(i, item);
        return;
      }
    }
    entries.add(item);
  }

  void sort(EntrySort s) => entries.sort(_compareFn(s));

  int Function(Entry, Entry) _compareFn(EntrySort s) {
    switch (s) {
      case EntrySort.TITLE:
        return (a, b) =>
            a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
      case EntrySort.TITLE_DESC:
        return (a, b) => b.titles[0].compareTo(a.titles[0]);
      case EntrySort.SCORE:
        return (a, b) {
          final comparison = a.score.compareTo(b.score);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        };
      case EntrySort.SCORE_DESC:
        return (a, b) {
          final comparison = b.score.compareTo(a.score);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        };
      case EntrySort.UPDATED_AT:
        return (a, b) {
          final comparison = a.updatedAt!.compareTo(b.updatedAt!);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        };
      case EntrySort.UPDATED_AT_DESC:
        return (a, b) {
          final comparison = b.updatedAt!.compareTo(a.updatedAt!);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        };
      case EntrySort.CREATED_AT:
        return (a, b) {
          final comparison = a.createdAt!.compareTo(b.createdAt!);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        };
      case EntrySort.CREATED_AT_DESC:
        return (a, b) {
          final comparison = b.createdAt!.compareTo(a.createdAt!);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        };
      case EntrySort.PROGRESS:
        return (a, b) {
          final comparison = a.progress.compareTo(b.progress);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        };
      case EntrySort.PROGRESS_DESC:
        return (a, b) {
          final comparison = b.progress.compareTo(a.progress);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        };
      case EntrySort.REPEAT:
        return (a, b) {
          final comparison = a.repeat.compareTo(b.repeat);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        };
      case EntrySort.REPEAT_DESC:
        return (a, b) {
          final comparison = b.repeat.compareTo(a.repeat);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        };
      case EntrySort.AIRING_AT:
        return (a, b) {
          if (a.airingAt == null) {
            if (b.airingAt == null) {
              return a.titles[0]
                  .toUpperCase()
                  .compareTo(b.titles[0].toUpperCase());
            }
            return 1;
          }

          if (b.airingAt == null) return -1;

          final comparison = a.airingAt!.compareTo(b.airingAt!);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        };
      case EntrySort.AIRING_AT_DESC:
        return (a, b) {
          if (b.airingAt == null) {
            if (a.airingAt == null) {
              return a.titles[0]
                  .toUpperCase()
                  .compareTo(b.titles[0].toUpperCase());
            }
            return -1;
          }

          if (a.airingAt == null) return 1;

          final comparison = b.airingAt!.compareTo(a.airingAt!);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        };
      case EntrySort.STARTED_RELEASING:
        return (a, b) {
          if (a.releaseStart == null) {
            if (b.releaseStart == null) {
              return a.titles[0]
                  .toUpperCase()
                  .compareTo(b.titles[0].toUpperCase());
            }
            return 1;
          }

          if (b.releaseStart == null) return -1;

          final comparison = a.releaseStart!.compareTo(b.releaseStart!);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        };
      case EntrySort.STARTED_RELEASING_DESC:
        return (a, b) {
          if (b.releaseStart == null) {
            if (a.releaseStart == null) {
              return a.titles[0]
                  .toUpperCase()
                  .compareTo(b.titles[0].toUpperCase());
            }
            return -1;
          }

          if (a.releaseStart == null) return 1;

          final comparison = b.releaseStart!.compareTo(a.releaseStart!);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        };
      case EntrySort.ENDED_RELEASING:
        return (a, b) {
          if (a.releaseEnd == null) {
            if (b.releaseEnd == null) {
              return a.titles[0]
                  .toUpperCase()
                  .compareTo(b.titles[0].toUpperCase());
            }
            return 1;
          }

          if (b.releaseEnd == null) return -1;

          final comparison = a.releaseEnd!.compareTo(b.releaseEnd!);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        };
      case EntrySort.ENDED_RELEASING_DESC:
        return (a, b) {
          if (b.releaseEnd == null) {
            if (a.releaseEnd == null) {
              return a.titles[0]
                  .toUpperCase()
                  .compareTo(b.titles[0].toUpperCase());
            }
            return -1;
          }

          if (a.releaseEnd == null) return 1;

          final comparison = b.releaseEnd!.compareTo(a.releaseEnd!);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        };
      case EntrySort.STARTED_WATCHING:
        return (a, b) {
          if (a.watchStart == null) {
            if (b.watchStart == null) {
              return a.titles[0]
                  .toUpperCase()
                  .compareTo(b.titles[0].toUpperCase());
            }
            return 1;
          }

          if (b.watchStart == null) return -1;

          final comparison = a.watchStart!.compareTo(b.watchStart!);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        };
      case EntrySort.STARTED_WATCHING_DESC:
        return (a, b) {
          if (b.watchStart == null) {
            if (a.watchStart == null) {
              return a.titles[0]
                  .toUpperCase()
                  .compareTo(b.titles[0].toUpperCase());
            }
            return -1;
          }

          if (a.watchStart == null) return 1;

          final comparison = b.watchStart!.compareTo(a.watchStart!);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        };
      case EntrySort.ENDED_WATCHING:
        return (a, b) {
          if (a.watchEnd == null) {
            if (b.watchEnd == null) {
              return a.titles[0]
                  .toUpperCase()
                  .compareTo(b.titles[0].toUpperCase());
            }
            return 1;
          }

          if (b.watchEnd == null) return -1;

          final comparison = a.watchEnd!.compareTo(b.watchEnd!);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        };
      case EntrySort.ENDED_WATCHING_DESC:
        return (a, b) {
          if (b.watchEnd == null) {
            if (a.watchEnd == null) {
              return a.titles[0]
                  .toUpperCase()
                  .compareTo(b.titles[0].toUpperCase());
            }
            return -1;
          }

          if (a.watchEnd == null) return 1;

          final comparison = b.watchEnd!.compareTo(a.watchEnd!);
          if (comparison != 0) return comparison;
          return a.titles[0].toUpperCase().compareTo(b.titles[0].toUpperCase());
        };
      default:
        return (_, __) => 0;
    }
  }
}

class Entry {
  Entry._({
    required this.mediaId,
    required this.titles,
    required this.imageUrl,
    required this.format,
    required this.status,
    required this.entryStatus,
    required this.nextEpisode,
    required this.airingAt,
    required this.createdAt,
    required this.updatedAt,
    required this.country,
    required this.genres,
    required this.tags,
    required this.progress,
    required this.progressMax,
    required this.progressVolumes,
    required this.progressVolumesMax,
    required this.repeat,
    required this.score,
    required this.notes,
    required this.releaseStart,
    required this.releaseEnd,
    required this.watchStart,
    required this.watchEnd,
  });

  factory Entry(Map<String, dynamic> map) {
    final titles = <String>[map['media']['title']['userPreferred']];
    if (map['media']['title']['english'] != null) {
      titles.add(map['media']['title']['english']);
    }
    if (map['media']['title']['romaji'] != null) {
      titles.add(map['media']['title']['romaji']);
    }
    if (map['media']['title']['native'] != null) {
      titles.add(map['media']['title']['native']);
    }

    final tags = <int>[];
    for (final t in map['media']['tags']) {
      tags.add(t['id']);
    }

    return Entry._(
      mediaId: map['media']['id'],
      titles: titles,
      imageUrl: map['media']['coverImage'][Settings().imageQuality],
      format: map['media']['format'],
      status: map['media']['status'],
      entryStatus: EntryStatus.values.byName(map['status']),
      nextEpisode: map['media']['nextAiringEpisode']?['episode'],
      airingAt: map['media']['nextAiringEpisode']?['airingAt'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      country: map['media']['countryOfOrigin'],
      genres: List.from(map['media']['genres'] ?? [], growable: false),
      tags: tags,
      progress: map['progress'] ?? 0,
      progressMax: map['media']['episodes'] ?? map['media']['chapters'],
      progressVolumes: map['progressVolumes'] ?? 0,
      progressVolumesMax: map['media']['volumes'],
      repeat: map['repeat'] ?? 0,
      score: map['score'].toDouble() ?? 0.0,
      notes: map['notes'],
      releaseStart: Convert.mapToMillis(map['media']['startDate']),
      releaseEnd: Convert.mapToMillis(map['media']['endDate']),
      watchStart: Convert.mapToMillis(map['startedAt']),
      watchEnd: Convert.mapToMillis(map['completedAt']),
    );
  }

  final int mediaId;
  final List<String> titles;
  final String imageUrl;
  final String? format;
  final String? status;
  final EntryStatus? entryStatus;
  final int? nextEpisode;
  final int? airingAt;
  final int? createdAt;
  final int? updatedAt;
  final String? country;
  final List<String> genres;
  final List<int> tags;
  int progress;
  final int? progressMax;
  final int progressVolumes;
  final int? progressVolumesMax;
  int repeat;
  double score;
  String? notes;
  int? releaseStart;
  int? releaseEnd;
  int? watchStart;
  int? watchEnd;
}

enum EntryStatus {
  CURRENT,
  PLANNING,
  COMPLETED,
  DROPPED,
  PAUSED,
  REPEATING,
}
