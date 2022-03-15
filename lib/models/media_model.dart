import 'package:otraku/constants/explorable.dart';
import 'package:otraku/models/edit_model.dart';
import 'package:otraku/models/media_stats_model.dart';
import 'package:otraku/models/recommended_model.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/models/media_info_model.dart';
import 'package:otraku/models/related_media_model.dart';
import 'package:otraku/models/related_review_model.dart';
import 'package:otraku/models/connection_model.dart';
import 'package:otraku/models/page_model.dart';

class MediaModel {
  final MediaInfoModel info;
  late EditModel entry;
  final MediaStatsModel stats;
  final List<RelatedMediaModel> otherMedia;
  final _recommendations = PageModel<RecommendedModel>();
  final _characters = PageModel<ConnectionModel>();
  final _staff = PageModel<ConnectionModel>();
  final _reviews = PageModel<RelatedReviewModel>();

  PageModel<RecommendedModel> get recommendations => _recommendations;
  PageModel<ConnectionModel> get characters => _characters;
  PageModel<ConnectionModel> get staff => _staff;
  PageModel<RelatedReviewModel> get reviews => _reviews;

  MediaModel._({
    required this.info,
    required this.entry,
    required this.stats,
    required this.otherMedia,
  });

  factory MediaModel(final Map<String, dynamic> map) {
    final other = <RelatedMediaModel>[];
    for (final relation in map['relations']['edges'])
      if (relation['node'] != null) other.add(RelatedMediaModel(relation));

    return MediaModel._(
      info: MediaInfoModel(map),
      entry: EditModel(map),
      stats: MediaStatsModel(map),
      otherMedia: other,
    )..addReviews(map);
  }

  void addRecommendations(Map<String, dynamic> map) {
    final items = <RecommendedModel>[];
    for (final rec in map['recommendations']['nodes'])
      if (rec['mediaRecommendation'] != null) items.add(RecommendedModel(rec));

    _recommendations.append(
      items,
      map['recommendations']['pageInfo']['hasNextPage'],
    );
  }

  void addCharacters(Map<String, dynamic> map, List<String> languages) {
    final items = <ConnectionModel>[];
    for (final connection in map['characters']['edges']) {
      final voiceActors = <ConnectionModel>[];
      for (final va in connection['voiceActors']) {
        final language = Convert.clarifyEnum(va['language']);
        if (language != null && !languages.contains(language))
          languages.add(language);

        voiceActors.add(ConnectionModel(
          id: va['id'],
          title: va['name']['userPreferred'],
          imageUrl: va['image']['large'],
          type: Explorable.staff,
          subtitle: language,
        ));
      }

      items.add(ConnectionModel(
        id: connection['node']['id'],
        title: connection['node']['name']['userPreferred'],
        imageUrl: connection['node']['image']['large'],
        subtitle: Convert.clarifyEnum(connection['role']),
        type: Explorable.character,
        other: voiceActors,
      ));
    }

    _characters.append(items, map['characters']['pageInfo']['hasNextPage']);
  }

  void addStaff(Map<String, dynamic> map) {
    final items = <ConnectionModel>[];
    for (final connection in map['staff']['edges'])
      items.add(ConnectionModel(
        id: connection['node']['id'],
        title: connection['node']['name']['userPreferred'],
        subtitle: connection['role'],
        imageUrl: connection['node']['image']['large'],
        type: Explorable.staff,
      ));

    _staff.append(items, map['staff']['pageInfo']['hasNextPage']);
  }

  void addReviews(Map<String, dynamic> map) {
    final items = <RelatedReviewModel>[];
    for (final r in map['reviews']['nodes'])
      try {
        items.add(RelatedReviewModel(r));
      } catch (_) {}

    _reviews.append(items, map['reviews']['pageInfo']['hasNextPage']);
  }
}
