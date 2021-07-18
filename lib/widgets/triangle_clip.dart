import 'package:flutter/material.dart';

class TriangleClip extends CustomClipper<Path> {
  const TriangleClip();

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.2, size.height);
    path.lineTo(size.width * 0.5, 0);
    path.lineTo(size.width * 0.8, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
