import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Design with ChangeNotifier {
  static const double ICON_BIG = 35;
  static const double ICON_MEDIUM = 30;
  static const double ICON_SMALL = 25;
  static const double ICON_SMALLER = 20;

  static const double FONT_BIG = 25;
  static const double FONT_MEDIUM = 20;
  static const double FONT_SMALL = 15;
  static const double FONT_SMALLER = 13;

  static ThemeData _theme;
  static Swatch _swatch;

  static Future<void> init() async {
    if (_theme != null) return;

    final preferences = await SharedPreferences.getInstance();

    final index = preferences.getInt('swatch');
    if (index == null) {
      _swatch = Swatch.slate;
    } else {
      _swatch = Swatch.values[index];
    }
    _buildTheme(_swatch);
  }

  static void _buildTheme(Swatch swatch) {
    _theme = ThemeData(
      fontFamily: 'Rubik',
      visualDensity: VisualDensity.adaptivePlatformDensity,
      brightness: swatch.colors['brightness'],
      backgroundColor: swatch.colors['background'],
      scaffoldBackgroundColor: swatch.colors['background'],
      primaryColor: swatch.colors['primary'],
      accentColor: swatch.colors['accent'],
      errorColor: swatch.colors['error'],
      cardColor: swatch.colors['translucent'],
      buttonColor: swatch.colors['accent'],
      dividerColor: swatch.colors['contrast'],
      disabledColor: swatch.colors['faded'],
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: swatch.colors['primary'],
        selectedItemColor: swatch.colors['accent'],
        unselectedItemColor: swatch.colors['faded'],
      ),
      iconTheme: IconThemeData(
        color: swatch.colors['faded'],
        size: ICON_MEDIUM,
      ),
      textTheme: TextTheme(
        headline1: TextStyle(
          fontSize: FONT_BIG,
          color: swatch.colors['faded'],
          fontWeight: FontWeight.w500,
        ),
        headline2: TextStyle(
          fontSize: FONT_MEDIUM,
          color: swatch.colors['accent'],
          fontWeight: FontWeight.w500,
        ),
        headline3: TextStyle(
          fontSize: FONT_MEDIUM,
          color: swatch.colors['contrast'],
          fontWeight: FontWeight.w500,
        ),
        headline5: TextStyle(
          fontSize: FONT_SMALL,
          color: swatch.colors['accent'],
          fontWeight: FontWeight.w500,
        ),
        headline6: TextStyle(
          fontSize: FONT_SMALL,
          color: swatch.colors['contrast'],
          fontWeight: FontWeight.w500,
        ),
        button: TextStyle(
          fontSize: FONT_MEDIUM,
          color: Colors.white,
        ),
        bodyText1: TextStyle(
          fontSize: FONT_SMALL,
          color: swatch.colors['contrast'],
          fontWeight: FontWeight.normal,
        ),
        bodyText2: TextStyle(
          fontSize: FONT_SMALL,
          color: swatch.colors['accent'],
          fontWeight: FontWeight.normal,
        ),
        subtitle1: TextStyle(
          fontSize: FONT_SMALL,
          color: swatch.colors['faded'],
        ),
        subtitle2: TextStyle(
          fontSize: FONT_SMALLER,
          color: swatch.colors['faded'],
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  ThemeData get theme {
    return _theme;
  }

  get swatch {
    return _swatch;
  }

  set swatch(Swatch value) {
    if (value == null) return;

    _swatch = value;
    _buildTheme(_swatch);

    notifyListeners();

    SharedPreferences.getInstance()
        .then((preferences) => preferences.setInt('swatch', value.index));
  }
}

enum Swatch {
  slate,
}

extension SwatchExtension on Swatch {
  static const _swatches = {
    Swatch.slate: {
      'background': Color(0xFF0F171E),
      'primary': Color(0xFF1D2835),
      'translucent': Color(0xBB0F171E),
      'accent': Color(0xFF45A0F2),
      'error': Color(0xFFD74761),
      'faded': Color(0xFF56789F),
      'contrast': Color(0xFFCAD5E2),
      'brightness': Brightness.dark,
    },
  };

  static const _names = {
    Swatch.slate: 'Slate',
  };

  Map<String, dynamic> get colors => _swatches[this];

  String get name => _names[this];
}
