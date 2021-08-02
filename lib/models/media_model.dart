import 'package:get/get.dart';
import 'package:otraku/enums/explorable.dart';
import 'package:otraku/models/entry_model.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/models/media_info_model.dart';
import 'package:otraku/models/related_media_model.dart';
import 'package:otraku/models/related_review_model.dart';
import 'package:otraku/models/connection_model.dart';
import 'package:otraku/models/page_model.dart';

class MediaModel {
  final MediaInfoModel info;
  late EntryModel entry;
  final List<RelatedMediaModel> otherMedia;
  final _characters = PageModel<ConnectionModel>().obs;
  final _staff = PageModel<ConnectionModel>().obs;
  final _reviews = PageModel<RelatedReviewModel>().obs;

  PageModel<ConnectionModel> get characters => _characters();
  PageModel<ConnectionModel> get staff => _staff();
  PageModel<RelatedReviewModel> get reviews => _reviews();

  MediaModel._(
    this.info,
    this.entry,
    this.otherMedia,
  );

  factory MediaModel(final Map<String, dynamic> map) {
    final other = <RelatedMediaModel>[];
    for (final relation in map['relations']['edges'])
      other.add(RelatedMediaModel(relation));

    return MediaModel._(
      MediaInfoModel(map),
      EntryModel(map),
      other,
    )..addReviews(map);
  }

  void addCharacters(
    final Map<String, dynamic> map,
    final List<String?> availableLanguages,
  ) {
    final items = <ConnectionModel>[];
    for (final connection in map['characters']['edges']) {
      final voiceActors = <ConnectionModel>[];
      for (final va in connection['voiceActors']) {
        final language = Convert.clarifyEnum(va['language']);
        if (!availableLanguages.contains(language))
          availableLanguages.add(language);

        voiceActors.add(ConnectionModel(
          id: va['id'],
          title: va['name']['full'],
          imageUrl: va['image']['large'],
          type: Explorable.staff,
          subtitle: language,
        ));
      }

      items.add(ConnectionModel(
        id: connection['node']['id'],
        title: connection['node']['name']['full'],
        imageUrl: connection['node']['image']['large'],
        subtitle: Convert.clarifyEnum(connection['role']),
        type: Explorable.character,
        other: voiceActors,
      ));
    }

    _characters.update(
      (c) => c!.append(items, map['characters']['pageInfo']['hasNextPage']),
    );
  }

  void addStaff(final Map<String, dynamic> map) {
    final items = <ConnectionModel>[];
    for (final connection in map['staff']['edges'])
      items.add(ConnectionModel(
        id: connection['node']['id'],
        title: connection['node']['name']['full'],
        subtitle: connection['role'],
        imageUrl: connection['node']['image']['large'],
        type: Explorable.staff,
      ));

    _staff.update(
      (s) => s!.append(items, map['staff']['pageInfo']['hasNextPage']),
    );
  }

  void addReviews(final Map<String, dynamic> map) {
    final items = <RelatedReviewModel>[];
    for (final r in map['reviews']['nodes'])
      try {
        items.add(RelatedReviewModel(r));
      } catch (_) {}

    _reviews.update(
      (r) => r!.append(items, map['reviews']['pageInfo']['hasNextPage']),
    );
  }
}
