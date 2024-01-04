import 'package:data_saver/data_saver.dart';
import 'package:otraku/common/utils/options.dart';

String _imageQuality = Options().imageQuality.value;

String get imageQuality => _imageQuality;

void refreshImageQuality() async {
  var quality = Options().imageQuality;
  var ignoreDataSaver = Options().ignoreDataSaverMode;

  if (!ignoreDataSaver) {
    var dataSaverMode = await const DataSaver().checkMode();
    if (dataSaverMode == DataSaverMode.enabled) {
      quality = ImageQuality.Medium;
    }
  }

  _imageQuality = quality.value;
}
