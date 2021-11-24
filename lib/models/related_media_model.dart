import 'package:otraku/constants/explorable.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/models/explorable_model.dart';

class RelatedMediaModel extends ExplorableModel {
  final String? relationType;
  final String? format;
  final String? status;

  RelatedMediaModel._({
    required this.relationType,
    required this.format,
    required this.status,
    required int id,
    required String title,
    required String? imageUrl,
    required Explorable explorable,
  }) : super(id: id, text1: title, imageUrl: imageUrl, explorable: explorable);

  factory RelatedMediaModel(Map<String, dynamic> map) => RelatedMediaModel._(
        id: map['node']['id'],
        title: map['node']['title']['userPreferred'],
        relationType: Convert.clarifyEnum(map['relationType']),
        format: Convert.clarifyEnum(map['node']['format']),
        status: Convert.clarifyEnum(map['node']['status']),
        imageUrl: map['node']['coverImage']['large'],
        explorable: map['node']['type'] == 'ANIME'
            ? Explorable.anime
            : Explorable.manga,
      );
}
