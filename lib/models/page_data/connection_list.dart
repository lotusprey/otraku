import 'package:otraku/models/sample_data/connection.dart';

class ConnectionList {
  final List<Connection> connections;
  bool _hasNextPage;
  int _nextPage = 2;

  ConnectionList(this.connections, this._hasNextPage);

  bool get hasNextPage => _hasNextPage;

  int get nextPage => _nextPage;

  void append(List<Connection> moreItems, bool hasNext) {
    connections.addAll(moreItems);
    _hasNextPage = hasNext;
    _nextPage++;
  }
}
