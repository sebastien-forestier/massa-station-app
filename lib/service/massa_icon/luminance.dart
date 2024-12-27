import 'dart:math' as math;

class SphereColor {
  int index;
  String hexColour;
  double luminance;
  SphereColor({required this.index, required this.hexColour, required this.luminance});
}

double geLuminance(String hexColor) {
  String red = hexColor.substring(1, 3);
  String green = hexColor.substring(3, 5);
  String blue = hexColor.substring(5);
  double redDouble = int.parse(red, radix: 16).toDouble() / 255.0;
  double greenDouble = int.parse(green, radix: 16).toDouble() / 255.0;
  double blueDouble = int.parse(blue, radix: 16).toDouble() / 255;

  var l = (0.2126 * sRGBToLin(redDouble) + 0.7152 * sRGBToLin(greenDouble) + 0.0722 * sRGBToLin(blueDouble));
  return getPerceivedLuminace(l);
}

List<SphereColor> getSortedColorByLuminance(List<String> colours) {
  List<SphereColor> myColors = [];
  for (int i = 0; i < colours.length; i++) {
    print(colours[i]);
    var luminance = geLuminance(colours[i]);
    myColors.add(SphereColor(index: i, hexColour: colours[i], luminance: luminance));
  }
  myColors.sort((a, b) => a.luminance.compareTo(b.luminance));
  return myColors;
}

double sRGBToLin(double colour) {
  if (colour <= 0.04045) {
    return colour / 12.92;
  } else {
    return math.pow(((colour + 0.055) / 1.055), 2.4).toDouble();
  }
}

double getPerceivedLuminace(double lum) {
  if (lum <= (216.0 / 24389.0)) {
    return lum * (24389.0 / 27.0);
  } else {
    return math.pow(lum, (1 / 3)) * 116 - 16;
  }
}
