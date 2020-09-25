import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Theming with ChangeNotifier {
  Palette _palette;
  int _swatchIndex;

  Future<void> init() async {
    final preferences = await SharedPreferences.getInstance();

    _swatchIndex = preferences.getInt('swatch');
    if (_swatchIndex == null) {
      _swatchIndex = 0;
      preferences.setInt('swatch', 0);
    }

    _palette = Palette(Palette.SWATCHES[_swatchIndex]);
  }

  get palette {
    return _palette;
  }

  get swatchIndex {
    return _swatchIndex;
  }

  set swatchIndex(int index) {
    _swatchIndex = index;
    _palette = Palette(Palette.SWATCHES[_swatchIndex]);

    SharedPreferences.getInstance()
        .then((preferences) => preferences.setInt('swatch', _swatchIndex));
  }
}

class Palette {
  static const double ICON_BIG = 35;
  static const double ICON_MEDIUM = 30;
  static const double ICON_SMALL = 25;
  static const double ICON_SMALLER = 20;

  static const double FONT_BIG = 25;
  static const double FONT_MEDIUM = 20;
  static const double FONT_SMALL = 15;

  static const SWATCHES = [
    const Swatch(
      name: 'Slate',
      background: Color(0xFF0F171E),
      foreground: Color(0xFF2B3C4F),
      translucent: Color(0xBB0F171E),
      accent: Color(0xFF45A0F2),
      error: Color(0xFFD74761),
      faded: Color(0xFF56789F),
      contrast: Color(0xFFCAD5E2),
    ),
  ];

  Swatch _swatch;
  TextStyle _headline;
  TextStyle _accentedTitle;
  TextStyle _contrastedTitle;
  TextStyle _buttonText;
  TextStyle _paragraph;
  TextStyle _exclamation;
  TextStyle _detail;

  Palette(this._swatch) {
    _headline = TextStyle(
      fontSize: FONT_BIG,
      color: _swatch.faded,
      fontWeight: FontWeight.w500,
    );

    _accentedTitle = TextStyle(
      fontSize: FONT_MEDIUM,
      color: _swatch.accent,
      fontWeight: FontWeight.w500,
    );

    _contrastedTitle = TextStyle(
      fontSize: FONT_MEDIUM,
      color: _swatch.contrast,
      fontWeight: FontWeight.w500,
    );

    _buttonText = TextStyle(
      fontSize: FONT_MEDIUM,
      color: Colors.white,
    );

    _paragraph = TextStyle(
      fontSize: FONT_SMALL,
      color: _swatch.contrast,
    );

    _exclamation = TextStyle(
      fontSize: FONT_SMALL,
      color: _swatch.accent,
    );

    _detail = TextStyle(
      fontSize: FONT_SMALL,
      color: _swatch.faded,
    );
  }

  get background {
    return _swatch.background;
  }

  get foreground {
    return _swatch.foreground;
  }

  get translucent {
    return _swatch.translucent;
  }

  get accent {
    return _swatch.accent;
  }

  get error {
    return _swatch.error;
  }

  get contrast {
    return _swatch.contrast;
  }

  get faded {
    return _swatch.faded;
  }

  get headline {
    return _headline;
  }

  get accentedTitle {
    return _accentedTitle;
  }

  get contrastedTitle {
    return _contrastedTitle;
  }

  get buttonText {
    return _buttonText;
  }

  get paragraph {
    return _paragraph;
  }

  get exclamation {
    return _exclamation;
  }

  get detail {
    return _detail;
  }
}

class Swatch {
  final String name;
  final Color background;
  final Color foreground;
  final Color translucent;
  final Color accent;
  final Color error;
  final Color contrast;
  final Color faded;

  const Swatch({
    @required this.name,
    @required this.background,
    @required this.foreground,
    @required this.translucent,
    @required this.accent,
    @required this.error,
    @required this.contrast,
    @required this.faded,
  });
}
