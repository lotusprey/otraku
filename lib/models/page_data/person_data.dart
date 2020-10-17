import 'package:flutter/foundation.dart';
import 'package:otraku/models/page_data/page_item_data.dart';
import 'package:otraku/models/sample_data/connection.dart';

class PersonData extends PageItemData {
  final String fullName;
  final List<String> altNames;
  final String imageUrl;
  final String description;
  final List<Connection> leftConnections;
  final List<Connection> rightConnections;
  bool _leftHasNextPage;
  bool _rightHasNextPage;
  bool currentlyOnLeftPage = true;
  int _leftNextPage = 2;
  int _rightNextPage = 2;

  PersonData({
    this.leftConnections = const [],
    this.rightConnections = const [],
    @required this.fullName,
    @required this.altNames,
    @required this.imageUrl,
    @required this.description,
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

  bool get hasNextPage {
    if (currentlyOnLeftPage) return _leftHasNextPage;
    return _rightHasNextPage;
  }

  int get nextPage {
    if (currentlyOnLeftPage) return _leftNextPage;
    return _rightNextPage;
  }

  List<Connection> get connections {
    if (currentlyOnLeftPage) return leftConnections;
    return rightConnections;
  }

  void appendLeft(List<Connection> primary, bool hasNext) {
    leftConnections.addAll(primary);
    _leftNextPage++;
    _leftHasNextPage = hasNext;
  }

  void appendRight(List<Connection> secondary, bool hasNext) {
    rightConnections.addAll(secondary);
    _rightNextPage++;
    _rightHasNextPage = hasNext;
  }
}
