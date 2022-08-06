import 'package:otraku/constants/explorable.dart';
import 'package:otraku/edit/edit_model.dart';
import 'package:otraku/models/media_stats_model.dart';
import 'package:otraku/models/recommended_model.dart';
import 'package:otraku/models/relation.dart';
import 'package:otraku/settings/user_settings.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/models/media_info_model.dart';
import 'package:otraku/models/related_media_model.dart';
import 'package:otraku/models/related_review_model.dart';
import 'package:otraku/models/page_model.dart';

class MediaModel {
  MediaModel._({required this.info, required this.edit, required this.stats});

  factory MediaModel(Map<String, dynamic> map, UserSettings settings) {
    final other = <RelatedMediaModel>[];
    for (final relation in map['relations']['edges'])
      if (relation['node'] != null) other.add(RelatedMediaModel(relation));

    return MediaModel._(
      info: MediaInfoModel(map),
      edit: Edit(map, settings),
      stats: MediaStatsModel(map),
    )
      ..otherMedia.addAll(other)
      ..addReviews(map);
  }

  late Edit edit;
  final MediaInfoModel info;
  final MediaStatsModel stats;
  final otherMedia = <RelatedMediaModel>[];
  final recommendations = PageModel<RecommendedModel>();
  final staff = PageModel<Relation>();
  final reviews = PageModel<RelatedReviewModel>();
  final characters = PageModel<Relation>();
  final _voiceActors = <String, Map<int, List<Relation>>>{};

  void selectCharactersAndVoiceActors(
    String language,
    List<Relation> characterList,
    List<Relation?> voiceActorList,
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
    final items = <Relation>[];
    for (final c in map['characters']['edges']) {
      items.add(Relation(
        id: c['node']['id'],
        title: c['node']['name']['userPreferred'],
        imageUrl: c['node']['image']['large'],
        subtitle: Convert.clarifyEnum(c['role']),
        type: Explorable.character,
      ));

      if (c['voiceActors'] != null)
        for (final va in c['voiceActors']) {
          final l = Convert.clarifyEnum(va['languageV2']);
          if (l == null) continue;

          if (!languages.contains(l)) languages.add(l);

          final currentLanguage = _voiceActors.putIfAbsent(
            l,
            () => <int, List<Relation>>{},
          );

          final currentCharacter = currentLanguage.putIfAbsent(
            items.last.id,
            () => [],
          );

          currentCharacter.add(Relation(
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
    final items = <Relation>[];
    for (final connection in map['staff']['edges'])
      items.add(Relation(
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
