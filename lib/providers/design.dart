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

  ThemeData _theme;
  Swatch _swatch;

  Future<void> init() async {
    if (_theme != null) return;

    final preferences = await SharedPreferences.getInstance();

    final index = preferences.getInt('swatch');
    if (index == null) {
      swatch = Swatch.slate;
    } else {
      swatch = Swatch.values[index];
    }
  }

  ThemeData get theme {
    return _theme;
  }

  Swatch get swatch {
    return _swatch;
  }

  set swatch(Swatch value) {
    _swatch = value;

    _theme = ThemeData(
      fontFamily: 'Rubik',
      visualDensity: VisualDensity.adaptivePlatformDensity,
      brightness: _swatch.colors['brightness'],
      backgroundColor: _swatch.colors['background'],
      scaffoldBackgroundColor: _swatch.colors['background'],
      primaryColor: _swatch.colors['primary'],
      accentColor: _swatch.colors['accent'],
      errorColor: _swatch.colors['error'],
      cardColor: _swatch.colors['translucent'],
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      buttonColor: _swatch.colors['accent'],
      dividerColor: _swatch.colors['contrast'],
      disabledColor: _swatch.colors['faded'],
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _swatch.colors['primary'],
        selectedItemColor: _swatch.colors['accent'],
        unselectedItemColor: _swatch.colors['faded'],
      ),
      iconTheme: IconThemeData(
        color: _swatch.colors['faded'],
        size: ICON_MEDIUM,
      ),
      textTheme: TextTheme(
        headline1: TextStyle(
          fontSize: FONT_BIG,
          color: _swatch.colors['faded'],
          fontWeight: FontWeight.w500,
        ),
        headline2: TextStyle(
          fontSize: FONT_MEDIUM,
          color: _swatch.colors['accent'],
          fontWeight: FontWeight.w500,
        ),
        headline3: TextStyle(
          fontSize: FONT_MEDIUM,
          color: _swatch.colors['contrast'],
          fontWeight: FontWeight.w500,
        ),
        button: TextStyle(
          fontSize: FONT_MEDIUM,
          color: Colors.white,
        ),
        subtitle1: TextStyle(
          fontSize: FONT_SMALL,
          color: _swatch.colors['faded'],
        ),
        bodyText1: TextStyle(
          fontSize: FONT_SMALL,
          color: _swatch.colors['contrast'],
        ),
        bodyText2: TextStyle(
          fontSize: FONT_SMALL,
          color: _swatch.colors['accent'],
        ),
      ),
    );

    notifyListeners();

    SharedPreferences.getInstance()
        .then((preferences) => preferences.setInt('swatch', _swatch.index));
  }
}

enum Swatch {
  slate,
}

extension SwatchExtension on Swatch {
  static const _swatches = {
    Swatch.slate: {
      'background': Color(0xFF0F171E),
      'primary': Color(0xFF2B3C4F),
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
