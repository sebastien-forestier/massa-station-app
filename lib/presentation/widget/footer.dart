// Flutter imports:
import 'package:flutter/material.dart';

Widget footer() {
  const double fontSize = 12;
  const Color color = Color(0xFFafb8ba);
  // PreferencesStorage.isThemeDark ? Color(0xFFafb8ba) : Color(0xFF8e989c);
  const TextStyle style = TextStyle(color: color, fontSize: fontSize);
  const footerSecondText = 'Developed by Nafsi Labs Limited';
  final madeWith = footerSecondText[0];
  final onEarth = footerSecondText[1];

  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      children: [
        const Text('Nafsi', style: style),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(madeWith, style: style),
            Text(
              '♥',
              style: style.copyWith(fontFamily: 'NotoMonochromaticEmoji'),
            ),
            Text(onEarth, style: style)
          ],
        ),
      ],
    ),
  );
}
