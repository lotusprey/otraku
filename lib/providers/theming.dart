import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Theming with ChangeNotifier {
  static bool _isDark;
  static Accent _accent;

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
      _accent = Accent.blue;
      preferences.setInt('accents', Accent.blue.index);
    } else {
      _accent = Accent.values[index];
    }

    if (_isDark) {
      _palette = Palette.dark(_accent);
    } else {
      _palette = Palette.light(_accent);
    }
  }

  void _saveConfig({bool isDarkValue, Accent accentValue}) async {
    final preferences = await SharedPreferences.getInstance();

    if (isDarkValue != null) {
      _isDark = isDarkValue;
      preferences.setBool('isDark', isDarkValue);
    }

    if (accentValue != null) {
      _accent = accentValue;
      preferences.setInt('accents', accentValue.index);
    }
  }

  void setTheme({@required bool toDark}) {
    if (toDark == _isDark) {
      return;
    }

    if (toDark) {
      _palette = Palette.dark(_accent);
      _saveConfig(isDarkValue: true);
    } else {
      _palette = Palette.light(_accent);
      _saveConfig(isDarkValue: false);
    }
    notifyListeners();
  }

  void setAccent(Accent accent) {
    if (accent == _accent) {
      return;
    }

    if (_isDark) {
      _palette = Palette.dark(accent);
    } else {
      _palette = Palette.light(accent);
    }
    _saveConfig(accentValue: accent);
    notifyListeners();
  }

  Palette get palette {
    return _palette;
  }

  bool get isDark {
    return _isDark;
  }

  Accent get accent {
    return _accent;
  }
}

class Palette {
  static const double ICON_BIG = 35;
  static const double ICON_MEDIUM = 30;
  static const double ICON_SMALL = 25;

  static const double FONT_BIG = 30;
  static const double FONT_MEDIUM = 20;
  static const double FONT_SMALL = 15;

  static const Color ERROR = Color(0xffeb1730);

  final Color background;
  final Color primary;
  final Color accent;
  final Color contrast;
  final Color faded;
  final TextStyle headline;
  final TextStyle accentedTitle;
  final TextStyle contrastedTitle;
  final TextStyle smallTitle;
  final TextStyle buttonText;
  final TextStyle exclamation;
  final TextStyle paragraph;
  final TextStyle detail;

  Palette.light(Accent accent)
      : this._(
          background: Colors.white,
          primary: Color(0xffe6eaed),
          accent: accent.color,
          contrast: Colors.black,
          faded: Color(0xff4a4a4a),
          headline: TextStyle(
            fontSize: FONT_BIG,
            color: Color(0xff4a4a4a),
            fontWeight: FontWeight.w500,
          ),
          accentedTitle: TextStyle(
            fontSize: FONT_MEDIUM,
            color: accent.color,
            fontWeight: FontWeight.w500,
          ),
          contrastedTitle: TextStyle(
            fontSize: FONT_MEDIUM,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
          smallTitle: TextStyle(
            fontSize: FONT_SMALL,
            color: Color(0xff4a4a4a),
            fontWeight: FontWeight.w500,
          ),
          buttonText: TextStyle(
            fontSize: FONT_MEDIUM,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          exclamation: TextStyle(
            fontSize: FONT_SMALL,
            color: accent.color,
          ),
          paragraph: TextStyle(
            fontSize: FONT_SMALL,
            color: Colors.black,
          ),
          detail: TextStyle(
            fontSize: FONT_SMALL,
            color: Color(0xff4a4a4a),
          ),
          brightness: Brightness.dark,
        );

  Palette.dark(Accent accent)
      : this._(
          background: Colors.black,
          primary: Color(0xff212121),
          accent: accent.color,
          contrast: Colors.white,
          faded: Color(0xff999999),
          headline: TextStyle(
            fontSize: FONT_BIG,
            color: Color(0xff999999),
            fontWeight: FontWeight.w500,
          ),
          accentedTitle: TextStyle(
            fontSize: FONT_MEDIUM,
            color: accent.color,
            fontWeight: FontWeight.w500,
          ),
          contrastedTitle: TextStyle(
            fontSize: FONT_MEDIUM,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          smallTitle: TextStyle(
            fontSize: FONT_SMALL,
            color: Color(0xff999999),
            fontWeight: FontWeight.w500,
          ),
          buttonText: TextStyle(
            fontSize: FONT_MEDIUM,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          exclamation: TextStyle(
            fontSize: FONT_SMALL,
            color: accent.color,
          ),
          paragraph: TextStyle(
            fontSize: FONT_SMALL,
            color: Colors.white,
          ),
          detail: TextStyle(
            fontSize: FONT_SMALL,
            color: Color(0xff999999),
          ),
          brightness: Brightness.light,
        );

  Palette._({
    @required this.background,
    @required this.primary,
    @required this.accent,
    @required this.contrast,
    @required this.faded,
    @required this.headline,
    @required this.accentedTitle,
    @required this.contrastedTitle,
    @required this.smallTitle,
    @required this.buttonText,
    @required this.exclamation,
    @required this.paragraph,
    @required this.detail,
    @required Brightness brightness,
  }) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: brightness,
      systemNavigationBarIconBrightness: brightness,
      statusBarColor: background,
      systemNavigationBarColor: background,
      systemNavigationBarDividerColor: background,
    ));
  }
}

enum Accent {
  blue,
  orange,
  green,
  purple,
}

extension AccentsExtension on Accent {
  static const _colors = const {
    Accent.blue: Color(0xff2172b5),
    Accent.orange: Color(0xffeda60c),
    Accent.green: Color(0xff32a852),
    Accent.purple: Color(0xff692de3),
  };

  Color get color => _colors[this];
}
