import 'package:otraku/constants/explorable.dart';
import 'package:otraku/models/edit_model.dart';
import 'package:otraku/models/media_stats_model.dart';
import 'package:otraku/models/recommended_model.dart';
import 'package:otraku/models/relation_model.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/models/media_info_model.dart';
import 'package:otraku/models/related_media_model.dart';
import 'package:otraku/models/related_review_model.dart';
import 'package:otraku/models/page_model.dart';

class MediaModel {
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

  final MediaInfoModel info;
  late EditModel entry;
  final MediaStatsModel stats;
  final List<RelatedMediaModel> otherMedia;
  final recommendations = PageModel<RecommendedModel>();
  final staff = PageModel<RelationModel>();
  final reviews = PageModel<RelatedReviewModel>();
  final characters = PageModel<RelationModel>();
  final _voiceActors = <String, Map<int, List<RelationModel>>>{};

  void selectCharactersAndVoiceActors(
    String language,
    List<RelationModel> characterList,
    List<RelationModel?> voiceActorList,
  ) {
    final byLanguage = _voiceActors[language];
    if (byLanguage == null) {
      characterList.addAll(characters.items);
      return;
    }

    for (final c in characters.items) {
      final vas = byLanguage[c.id];
      if (vas == null || vas.isEmpty) {
        characterList.add(c);
        voiceActorList.add(null);
        continue;
      }

      for (final va in vas) {
        characterList.add(c);
        voiceActorList.add(va);
      }
    }
  }

  void addRecommendations(Map<String, dynamic> map) {
    final items = <RecommendedModel>[];
    for (final rec in map['recommendations']['nodes'])
      if (rec['mediaRecommendation'] != null) items.add(RecommendedModel(rec));

    recommendations.append(
      items,
      map['recommendations']['pageInfo']['hasNextPage'],
    );
  }

  void addCharacters(Map<String, dynamic> map, List<String> languages) {
    final items = <RelationModel>[];
    for (final c in map['characters']['edges']) {
      items.add(RelationModel(
        id: c['node']['id'],
        title: c['node']['name']['userPreferred'],
        imageUrl: c['node']['image']['large'],
        subtitle: Convert.clarifyEnum(c['role']),
        type: Explorable.character,
      ));

      if (c['voiceActors'] != null)
        for (final va in c['voiceActors']) {
          final l = Convert.clarifyEnum(va['language']);
          if (l == null) continue;

          if (!languages.contains(l)) languages.add(l);

          final currentLanguage = _voiceActors.putIfAbsent(
            l,
            () => <int, List<RelationModel>>{},
          );

          final currentCharacter =
              currentLanguage.putIfAbsent(items.last.id, () => []);

          currentCharacter.add(RelationModel(
            id: va['id'],
            title: va['name']['userPreferred'],
            imageUrl: va['image']['large'],
            subtitle: l,
            type: Explorable.staff,
          ));
        }
    }

    characters.append(items, map['characters']['pageInfo']['hasNextPage']);
  }

  void addStaff(Map<String, dynamic> map) {
    final items = <RelationModel>[];
    for (final connection in map['staff']['edges'])
      items.add(RelationModel(
        id: connection['node']['id'],
        title: connection['node']['name']['userPreferred'],
        imageUrl: connection['node']['image']['large'],
        subtitle: connection['role'],
        type: Explorable.staff,
      ));

    staff.append(items, map['staff']['pageInfo']['hasNextPage']);
  }

  void addReviews(Map<String, dynamic> map) {
    final items = <RelatedReviewModel>[];
    for (final r in map['reviews']['nodes'])
      try {
        items.add(RelatedReviewModel(r));
      } catch (_) {}

    reviews.append(items, map['reviews']['pageInfo']['hasNextPage']);
  }
}
