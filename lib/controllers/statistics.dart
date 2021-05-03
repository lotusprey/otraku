import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/user.dart';
import 'package:otraku/models/statistics_model.dart';
import 'package:otraku/models/user_model.dart';

class Statistics extends GetxController {
  Statistics(this.id);
  final int id;
  final _scoresOnCount = true.obs;
  final _keys = [UniqueKey(), UniqueKey()];
  late UserModel _model;
  bool _onAnime = true;

  UniqueKey get key => _onAnime ? _keys[0] : _keys[1];
  StatisticsModel get model => _onAnime ? _model.animeStats : _model.mangaStats;

  bool get scoresOnCount => _scoresOnCount();
  set scoresOnCount(bool val) => _scoresOnCount(val);

  bool get onAnime => _onAnime;
  set onAnime(bool val) {
    _onAnime = val;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    _model = Get.find<User>(tag: id.toString()).model!;
  }
}
