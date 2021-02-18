import 'package:get/get.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/helpers/fn_helper.dart';
import 'package:otraku/models/anilist/media_overview_model.dart';
import 'package:otraku/models/anilist/related_media_model.dart';
import 'package:otraku/models/anilist/related_review_model.dart';
import 'package:otraku/models/connection.dart';
import 'package:otraku/models/loadable_list.dart';

class MediaModel {
  final _overview = Rx<MediaOverviewModel>();
  final _otherMedia = List<RelatedMediaModel>().obs;
  final _characters = Rx(LoadableList<Connection>([], true));
  final _staff = Rx(LoadableList<Connection>([], true));
  final _reviews = Rx(LoadableList<RelatedReviewModel>([], true));

  MediaOverviewModel get overview => _overview();
  List<RelatedMediaModel> get otherMedia => _otherMedia();
  LoadableList get characters => _characters();
  LoadableList get staff => _staff();
  LoadableList get reviews => _reviews();

  void setMain(final Map<String, dynamic> map) {
    _overview(MediaOverviewModel(map));

    final List<RelatedMediaModel> om = [];
    for (final relation in map['relations']['edges'])
      om.add(RelatedMediaModel(relation));
    _otherMedia.addAll(om);
  }

  void addCharacters(
    final Map<String, dynamic> map,
    final List<String> availableLanguages,
  ) {
    final List<Connection> items = [];
    for (final connection in map['characters']['edges']) {
      final List<Connection> voiceActors = [];
      for (final va in connection['voiceActors']) {
        final language = FnHelper.clarifyEnum(va['language']);
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
        text2: FnHelper.clarifyEnum(connection['role']),
        imageUrl: connection['node']['image']['large'],
        others: voiceActors,
        browsable: Browsable.character,
      ));
    }
    _characters.update(
      (c) => c.append(items, map['characters']['pageInfo']['hasNextPage']),
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
      (s) => s.append(items, map['staff']['pageInfo']['hasNextPage']),
    );
  }

  void addReviews(final Map<String, dynamic> map) {
    final List<RelatedReviewModel> items = [];
    for (final r in map['reviews']['nodes']) items.add(RelatedReviewModel(r));
    _reviews.update(
      (r) => r.append(items, map['reviews']['pageInfo']['hasNextPage']),
    );
  }
}
