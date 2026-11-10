import 'package:flutter/material.dart';

import '../theme/colors.dart';
class Loader extends StatelessWidget {
  final double size;

  const Loader({
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: primaryRedButtonColor,
      ),
    );
  }
}
