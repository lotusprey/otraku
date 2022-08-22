import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/utils/settings.dart';

final homeProvider = ChangeNotifierProvider.autoDispose(
  (ref) => HomeNotifier(),
);

class HomeNotifier extends ChangeNotifier {
  int _homeTab = Settings().defaultHomeTab;
  bool _inboxOnFeed = Settings().inboxOnFeed;

  int get homeTab => _homeTab;
  bool get inboxOnFeed => _inboxOnFeed;

  set homeTab(int val) {
    if (_homeTab == val) return;
    _homeTab = val;
    notifyListeners();
  }

  set inboxOnFeed(bool val) {
    if (_inboxOnFeed == val) return;
    _inboxOnFeed = val;
    Settings().inboxOnFeed = val;
    notifyListeners();
  }
}
