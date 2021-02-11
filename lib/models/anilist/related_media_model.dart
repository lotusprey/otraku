import 'package:flutter/foundation.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/helpers/fn_helper.dart';
import 'package:otraku/models/browse_result_model.dart';

class RelatedMediaModel extends BrowseResultModel {
  final String relationType;
  final String format;
  final String status;

  RelatedMediaModel._({
    @required this.relationType,
    @required this.format,
    @required this.status,
    @required int id,
    @required String title,
    @required String imageUrl,
    @required Browsable browsable,
  }) : super(id: id, title: title, imageUrl: imageUrl, browsable: browsable);

  factory RelatedMediaModel(Map<String, dynamic> map) => RelatedMediaModel._(
        id: map['node']['id'],
        title: map['node']['title']['userPreferred'],
        relationType: FnHelper.clarifyEnum(map['relationType']),
        format: FnHelper.clarifyEnum(map['node']['format']),
        status: FnHelper.clarifyEnum(map['node']['status']),
        imageUrl: map['node']['coverImage']['large'],
        browsable:
            map['node']['type'] == 'ANIME' ? Browsable.anime : Browsable.manga,
      );
}
