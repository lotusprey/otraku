import 'package:flutter/foundation.dart';
import 'package:otraku/models/page_data/page_item_data.dart';
import 'package:otraku/models/sample_data/browse_result.dart';
import 'package:otraku/models/tuple.dart';

class StudioData extends PageItemData {
  final String name;
  final Tuple<List<int>, List<List<BrowseResult>>> media;

  StudioData({
    @required this.name,
    @required this.media,
    @required id,
    @required isFavourite,
    @required favourites,
    @required browsable,
  }) : super(
          id: id,
          isFavourite: isFavourite,
          favourites: favourites,
          browsable: browsable,
        );
}
