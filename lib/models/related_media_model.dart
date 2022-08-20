import 'package:otraku/discover/discover_models.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/settings.dart';

class RelatedMediaModel {
  RelatedMediaModel._({
    required this.id,
    required this.type,
    required this.title,
    required this.imageUrl,
    required this.relationType,
    required this.format,
    required this.status,
  });

  factory RelatedMediaModel(Map<String, dynamic> map) => RelatedMediaModel._(
        id: map['node']['id'],
        title: map['node']['title']['userPreferred'],
        relationType: Convert.clarifyEnum(map['relationType'])!,
        format: Convert.clarifyEnum(map['node']['format']),
        status: Convert.clarifyEnum(map['node']['status']),
        imageUrl: map['node']['coverImage'][Settings().imageQuality],
        type: map['node']['type'] == 'ANIME'
            ? DiscoverType.anime
            : DiscoverType.manga,
      );

  final int id;
  final DiscoverType type;
  final String title;
  final String imageUrl;
  final String relationType;
  final String? format;
  final String? status;
}
