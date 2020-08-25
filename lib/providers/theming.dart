import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otraku/models/tuple.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Theming with ChangeNotifier {
  static bool _isDark;
  static Accents _accents;

  Palette _palette;

  Future<void> init() async {
    final preferences = await SharedPreferences.getInstance();

    _isDark = preferences.getBool('isDark');
    if (_isDark == null) {
      _isDark = false;
      preferences.setBool('isDark', false);
    }

    int index = preferences.getInt('accents');
    if (index == null) {
      _accents = Accents.blue;
      preferences.setInt('accents', Accents.blue.index);
    } else {
      _accents = Accents.values[index];
    }

    if (_isDark) {
      _palette = Palette.dark(_accents);
    } else {
      _palette = Palette.light(_accents);
    }
  }

  void _saveConfig({bool isDarkValue, Accents accentsValue}) async {
    final preferences = await SharedPreferences.getInstance();

    if (isDarkValue != null) {
      _isDark = isDarkValue;
      preferences.setBool('isDark', isDarkValue);
    }

    if (accentsValue != null) {
      _accents = accentsValue;
      preferences.setInt('accents', accentsValue.index);
    }
  }

  void setTheme({@required bool toDark}) {
    if (toDark == _isDark) {
      return;
    }

    if (toDark) {
      _palette = Palette.dark(_accents);
      _saveConfig(isDarkValue: true);
    } else {
      _palette = Palette.light(_accents);
      _saveConfig(isDarkValue: false);
    }
    notifyListeners();
  }

  void setAccent(Accents accents) {
    if (accents == _accents) {
      return;
    }

    if (_isDark) {
      _palette = Palette.dark(accents);
    } else {
      _palette = Palette.light(accents);
    }
    _saveConfig(accentsValue: accents);
    notifyListeners();
  }

  Palette get palette {
    return _palette;
  }

  bool get isDark {
    return _isDark;
  }

  Accents get accents {
    return _accents;
  }
}

class Palette {
  static const double ICON_BIG = 35;
  static const double ICON_MEDIUM = 30;
  static const double ICON_SMALL = 25;

  static const double FONT_BIG = 30;
  static const double FONT_MEDIUM = 20;
  static const double FONT_SMALL = 15;

  final Color background;
  final Color primary;
  final Color accent;
  final Color contrast;
  final Color faded;
  final Color error;
  final TextStyle headlineMain;
  final TextStyle titleAccented;
  final TextStyle titleContrasted;
  final TextStyle titleSmall;
  final TextStyle detail;
  final TextStyle paragraph;

  Palette.light(Accents accents)
      : this._(
          background: Colors.white,
          primary: Color(0xffe6eaed),
          accent: accents.swatch.item1,
          contrast: Colors.black,
          faded: Color(0xff4a4a4a),
          error: accents.swatch.item2,
          headlineMain: TextStyle(
            fontSize: FONT_BIG,
            color: Color(0xff4a4a4a),
            fontWeight: FontWeight.bold,
          ),
          titleAccented: TextStyle(
            fontSize: FONT_MEDIUM,
            color: accents.swatch.item1,
            fontWeight: FontWeight.bold,
          ),
          titleContrasted: TextStyle(
            fontSize: FONT_MEDIUM,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          titleSmall: TextStyle(
            fontSize: FONT_SMALL,
            color: Color(0xff4a4a4a),
            fontWeight: FontWeight.bold,
          ),
          detail: TextStyle(
            fontSize: FONT_SMALL,
            color: Color(0xff4a4a4a),
          ),
          paragraph: TextStyle(
            fontSize: FONT_SMALL,
            color: Colors.black,
          ),
          brightness: Brightness.dark,
        );

  Palette.dark(Accents accents)
      : this._(
          background: Colors.black,
          primary: Color(0xff141414),
          accent: accents.swatch.item1,
          contrast: Colors.white,
          faded: Color(0xff999999),
          error: accents.swatch.item2,
          headlineMain: TextStyle(
            fontSize: FONT_BIG,
            color: Color(0xff999999),
            fontWeight: FontWeight.bold,
          ),
          titleAccented: TextStyle(
            fontSize: FONT_MEDIUM,
            color: accents.swatch.item1,
            fontWeight: FontWeight.bold,
          ),
          titleContrasted: TextStyle(
            fontSize: FONT_MEDIUM,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          titleSmall: TextStyle(
            fontSize: FONT_SMALL,
            color: Color(0xff999999),
            fontWeight: FontWeight.bold,
          ),
          detail: TextStyle(
            fontSize: FONT_SMALL,
            color: Color(0xff999999),
          ),
          paragraph: TextStyle(
            fontSize: FONT_SMALL,
            color: Colors.white,
          ),
          brightness: Brightness.light,
        );

  Palette._({
    @required this.background,
    @required this.primary,
    @required this.accent,
    @required this.contrast,
    @required this.faded,
    @required this.error,
    @required this.headlineMain,
    @required this.titleAccented,
    @required this.titleContrasted,
    @required this.titleSmall,
    @required this.detail,
    @required this.paragraph,
    @required Brightness brightness,
  }) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: background,
      statusBarIconBrightness: brightness,
      systemNavigationBarColor: background,
      systemNavigationBarIconBrightness: brightness,
    ));
  }
}

enum Accents {
  blue,
  orange,
  green,
}

extension AccentsExtension on Accents {
  static const _swatches = const {
    Accents.blue: Tuple(
      Color(0xff216ead),
      Color(0xffdb3550),
    ),
    Accents.orange: Tuple(
      Color(0xffeda60c),
      Color(0xffdb3550),
    ),
    Accents.green: Tuple(
      Color(0xff32a852),
      Color(0xffdb3550),
    ),
  };

  Tuple<Color, Color> get swatch => _swatches[this];
}
