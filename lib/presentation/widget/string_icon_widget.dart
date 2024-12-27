import 'dart:math';
import 'package:flutter/material.dart';

class StringIcon extends StatelessWidget {
  final String inputString;
  final double iconSize;
  final int gridSize;

  const StringIcon({required this.inputString, this.iconSize = 100, this.gridSize = 5, super.key});

  @override
  Widget build(BuildContext context) {
    // Precompute pixel pattern and colors
    final pixelData = _generatePixelData(inputString, gridSize);
    final colors = _generateColorFromString(inputString);

    return Container(
      width: iconSize,
      height: iconSize,
      decoration: const BoxDecoration(
        color: Colors.black, // Background color
        shape: BoxShape.circle, // Ensures the shape is circular
      ),
      child: Padding(
        padding: EdgeInsets.all(iconSize * 0.2), // Shrink grid inside the circle
        child: Align(
          alignment: Alignment.center,
          child: CustomPaint(
            painter: StringIconPainter(colors: colors, pixels: pixelData, gridSize: gridSize),
            child: SizedBox(width: iconSize, height: iconSize),
          ),
        ),
      ),
    );
  }

  // Generate a list of booleans representing pixel presence
  List<bool> _generatePixelData(String input, int gridSize) {
    final random = Random(input.hashCode);
    return List.generate(gridSize * gridSize, (_) => random.nextBool());
  }

  // Precompute a list of bright colors based on the string
  List<Color> _generateColorFromString(String input) {
    final int hash = input.hashCode;
    // Ensure colors stay bright by keeping each color channel above 128
    final r = ((hash & 0xFF0000) >> 16) | 0x80;
    final g = ((hash & 0x00FF00) >> 8) | 0x80;
    final b = (hash & 0x0000FF) | 0x80;
    return [Color.fromARGB(255, r, g, b)];
  }
}

class StringIconPainter extends CustomPainter {
  final List<Color> colors;
  final List<bool> pixels; // Precomputed pixel pattern for faster rendering
  final int gridSize; // Size of the grid (e.g., 5 for a 5x5 grid)
  final Paint pixelPaint = Paint(); // Reuse paint object

  StringIconPainter({required this.colors, required this.pixels, this.gridSize = 5});

  @override
  void paint(Canvas canvas, Size size) {
    final double pixelSize = size.width / gridSize; // Size of each pixel in the grid
    int colorIndex = 0;

    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (pixels[i * gridSize + j]) {
          // Reuse the paint object with the current color
          pixelPaint.color = colors[colorIndex % colors.length];
          colorIndex++;
          final rect = Rect.fromLTWH(j * pixelSize, i * pixelSize, pixelSize, pixelSize);
          canvas.drawRect(rect, pixelPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // No need to repaint unless input changes
  }
}
