import 'package:get/get.dart';
import 'package:otraku/controllers/user_controller.dart';
import 'package:otraku/models/statistics_model.dart';
import 'package:otraku/models/user_model.dart';

class StatisticsController extends GetxController {
  // Bar chart tabs.
  static const BY_COUNT = 0;
  static const BY_HOUR_OR_CHAPTER = 1;
  static const BY_MEAN_SCORE = 2;

  // GetBuilder widget ids.
  static const ID_MAIN = 0;
  static const ID_SCORE = 1;
  static const ID_LENGTH = 2;

  StatisticsController(this.id);
  final int id;
  late UserModel _model;
  bool _onAnime = true;
  int _scoreChartTab = BY_COUNT;
  int _lengthChartTab = BY_COUNT;

  StatisticsModel get model => _onAnime ? _model.animeStats : _model.mangaStats;

  int get scoreChartTab => _scoreChartTab;
  set scoreChartTab(int val) {
    if (val != 0 && val != 1) return;
    _scoreChartTab = val;
    update([ID_SCORE]);
  }

  int get lengthChartTab => _lengthChartTab;
  set lengthChartTab(int val) {
    if (val < 0 || val > 2) return;
    _lengthChartTab = val;
    update([ID_LENGTH]);
  }

  bool get onAnime => _onAnime;
  set onAnime(bool val) {
    _onAnime = val;
    update([ID_MAIN]);
  }

  @override
  void onInit() {
    super.onInit();
    _model = Get.find<UserController>(tag: id.toString()).model!;
  }
}
