import 'package:get/get.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/models/entry_model.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/models/media_overview_model.dart';
import 'package:otraku/models/related_media_model.dart';
import 'package:otraku/models/related_review_model.dart';
import 'package:otraku/models/helper_models/connection.dart';
import 'package:otraku/models/page_model.dart';

class MediaModel {
  final MediaOverviewModel overview;
  final EntryModel entry;
  final List<RelatedMediaModel> otherMedia;
  final _characters = PageModel<Connection>().obs;
  final _staff = PageModel<Connection>().obs;
  final _reviews = PageModel<RelatedReviewModel>().obs;

  PageModel? get characters => _characters();
  PageModel? get staff => _staff();
  PageModel? get reviews => _reviews();

  MediaModel._(
    this.overview,
    this.entry,
    this.otherMedia,
  );

  factory MediaModel(final Map<String, dynamic> map) {
    final other = <RelatedMediaModel>[];
    for (final relation in map['relations']['edges'])
      other.add(RelatedMediaModel(relation));

    return MediaModel._(
      MediaOverviewModel(map),
      EntryModel(map),
      other,
    )..addReviews(map);
  }

  void addCharacters(
    final Map<String, dynamic> map,
    final List<String?> availableLanguages,
  ) {
    final List<Connection> items = [];
    for (final connection in map['characters']['edges']) {
      final List<Connection> voiceActors = [];
      for (final va in connection['voiceActors']) {
        final language = Convert.clarifyEnum(va['language']);
        if (!availableLanguages.contains(language))
          availableLanguages.add(language);

        voiceActors.add(Connection(
          id: va['id'],
          title: va['name']['full'],
          imageUrl: va['image']['large'],
          browsable: Browsable.staff,
          text2: language,
        ));
      }

      items.add(Connection(
        id: connection['node']['id'],
        title: connection['node']['name']['full'],
        text2: Convert.clarifyEnum(connection['role']),
        imageUrl: connection['node']['image']['large'],
        others: voiceActors,
        browsable: Browsable.character,
      ));
    }
    _characters.update(
      (c) => c!.append(items, map['characters']['pageInfo']['hasNextPage']),
    );
  }

  void addStaff(final Map<String, dynamic> map) {
    final List<Connection> items = [];
    for (final connection in map['staff']['edges'])
      items.add(Connection(
        id: connection['node']['id'],
        title: connection['node']['name']['full'],
        text2: connection['role'],
        imageUrl: connection['node']['image']['large'],
        browsable: Browsable.staff,
      ));
    _staff.update(
      (s) => s!.append(items, map['staff']['pageInfo']['hasNextPage']),
    );
  }

  void addReviews(final Map<String, dynamic> map) {
    final List<RelatedReviewModel> items = [];
    for (final r in map['reviews']['nodes']) items.add(RelatedReviewModel(r));
    _reviews.update(
      (r) => r!.append(items, map['reviews']['pageInfo']['hasNextPage']),
    );
  }
}
