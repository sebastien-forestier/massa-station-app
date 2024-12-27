import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mug/constants/asset_names.dart';
import 'package:mug/service/massa_icon/colors.dart';
import 'package:mug/service/massa_icon/luminance.dart';
import 'package:mug/service/massa_icon/sphere.dart';

SvgPicture generateSVG(String address) {
  var seed = getSeed(address);
  int iIndex = randBetwen(0, 992, seed.iSeed);
  int angle = randBetwen(10, 90, seed.ySeed);

  var colours = colorPaletteHex[iIndex];
  var sortedColours = getSortedColorByLuminance(colours);

//            <stop id="c" style="stop-color:black" offset=".9" />

  var svgTemplate = '''
<svg width="132" height="132" version="1.1" xmlns="http://www.w3.org/2000/svg">
    <defs>
        <radialGradient id="rg" gradientUnits="userSpaceOnUse" cx="$angle%" cy="30%" r="90%">
            <stop id="a" style="stop-color:${sortedColours[0].hexColour}" offset="0" />
            <stop id="b" style="stop-color:${sortedColours[2].hexColour}" offset=".5" />
        </radialGradient>
    </defs>
    <g>
        <circle cx="66" cy="66" r="66" fill="white" />
        <path
            d="M27.165 18.515l2.78-4.812-1.316-2.28-5.567-.004 3.223-5.578c-.877-.51-1.81-.93-2.792-1.246l-4.387 7.582 1.322 2.28h5.567l-2.782 4.818 1.314 2.284h8.507c.234-.978.368-2 .389-3.044h-6.258zM17.785 30.175h2.633l2.788-4.814 3.038 5.258a14.407 14.407 0 002.474-1.797l-4.191-7.263h-2.636l-2.788 4.819-2.781-4.819h-2.638l-4.19 7.263a14.424 14.424 0 002.474 1.798l3.037-5.257 2.78 4.812zM15 19.276l-2.78-4.819h5.562l1.324-2.28-4.387-7.582c-.982.316-1.916.737-2.792 1.246l3.221 5.576h-5.56L8.27 13.696l2.78 4.819H4.788a14.31 14.31 0 00.389 3.044h8.506L15 19.276z"
            fill="black" transform="scale(3) translate(3,3)" />
        <circle cx="66" cy="66" r="66.2" style="fill:url(#rg);fill-opacity:0.96;stroke:none" />
    </g>
</svg>
  ''';

//            <stop offset=".9" stop-color="black" />

  final svg2 = '''
<svg xmlns="http://www.w3.org/2000/svg" width="132" height="132">
    <defs>
        <radialGradient id="axx" cx="$angle%" cy="30%" r="90%" gradientUnits="userSpaceOnUse">
            <stop offset="0" stop-color="${sortedColours[0].hexColour}" />
            <stop offset=".5" stop-color="${sortedColours[4].hexColour}" />
           <stop offset="1" stop-color="black" />

        </radialGradient>
    </defs>
    <circle cx="66" cy="66" r="66" fill="#fff" />
    <path
        d="m90.495 64.545 8.34-14.436-3.948-6.84-16.701-.012 9.669-16.734a42.623 42.623 0 0 0-8.376-3.738L66.318 45.531l3.966 6.84h16.701l-8.346 14.454 3.942 6.852h25.521c.702-2.934 1.104-6 1.167-9.132H90.495zm-28.14 34.98h7.899l8.364-14.442 9.114 15.774a43.221 43.221 0 0 0 7.422-5.391L82.581 73.677h-7.908l-8.364 14.457-8.343-14.457h-7.914l-12.57 21.789a43.272 43.272 0 0 0 7.422 5.394l9.111-15.771 8.34 14.436zM54 66.828l-8.34-14.457h16.686l3.972-6.84-13.161-22.746a42.72 42.72 0 0 0-8.376 3.738l9.663 16.728h-16.68l-3.954 6.837 8.34 14.457H23.364a42.93 42.93 0 0 0 1.167 9.132h25.518L54 66.828z" />
    <circle cx="66" cy="66" r="66.2" fill="url(#axx)" fill-opacity=".90" />
</svg>
''';

  return SvgPicture.string(
    svgTemplate,
    width: 132,
    height: 132,
  );
}

// Function to generate a random number in a range
double generateRandomInRange(double min, double max, int seed) {
  Random random = Random(seed);
  return min + random.nextDouble() * (max - min);
}

Widget generateRadial(String address) {
  var seed = getSeed(address);
  int iIndex = randBetwen(0, 992, seed.iSeed);
  //double xpos = (randBetwen(10, 60, seed.xSeed) - 25) / 100;
  //double ypos = (randBetwen(10, 60, seed.ySeed) - 25) / 100;

  Random random = Random(seed.ySeed);

  // Decide randomly whether to pick from the positive or negative range
  bool pickPositive1 = random.nextBool();
  bool pickPositive2 = random.nextBool();

  double xpos;
  if (pickPositive1) {
    xpos = generateRandomInRange(0.2, 0.4, seed.xSeed); // Positive range
  } else {
    xpos = generateRandomInRange(-0.4, -0.2, seed.xSeed); // Negative range
  }

  double ypos;
  if (pickPositive2) {
    ypos = generateRandomInRange(0.2, 0.4, seed.ySeed); // Positive range
  } else {
    ypos = generateRandomInRange(-0.4, -0.2, seed.ySeed); // Negative range
  }
  var colours = colorPalettesInts[iIndex];
  //var colours2 = colorPaletteHex[iIndex];
  //final sortedColours = getSortedColorByLuminance(colours2);
  print("x = $xpos and y = $ypos");

  // print(colours);
  // print(colours2);
  // print(sortedColours);

  final pcolours = <String>["red", "blue", "green", "white", "yellow", "orange", "purple"];
  final cIndex = randBetwen(0, 6, seed.ySeed);

  final svg = '''<svg xmlns="http://www.w3.org/2000/svg" width="132" height="132">
    <path fill="${pcolours[cIndex]}" opacity="1.00000"
        d="m90.495 64.545 8.34-14.436-3.948-6.84-16.701-.012 9.669-16.734a42.623 42.623 0 0 0-8.376-3.738L66.318 45.531l3.966 6.84h16.701l-8.346 14.454 3.942 6.852h25.521c.702-2.934 1.104-6 1.167-9.132H90.495zm-28.14 34.98h7.899l8.364-14.442 9.114 15.774a43.221 43.221 0 0 0 7.422-5.391L82.581 73.677h-7.908l-8.364 14.457-8.343-14.457h-7.914l-12.57 21.789a43.272 43.272 0 0 0 7.422 5.394l9.111-15.771 8.34 14.436zM54 66.828l-8.34-14.457h16.686l3.972-6.84-13.161-22.746a42.72 42.72 0 0 0-8.376 3.738l9.663 16.728h-16.68l-3.954 6.837 8.34 14.457H23.364a42.93 42.93 0 0 0 1.167 9.132h25.518L54 66.828z" />
</svg>''';

  return Stack(
    children: [
      // Background image
      Positioned.fill(
        child: SvgPicture.string(svg),
      ),
      // Sphere overlay
      Center(
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: Alignment(xpos, ypos), // Light source
              radius: 0.8,
              colors: [
                Color(colours[0]).withValues(alpha: 0.4), // Bright spot
                Color(colours[4]).withValues(alpha: 0.6), // Mid-tone
                Colors.black.withValues(alpha: 0.9), // Shadow // Transparent bright spot
              ],
              stops: const <double>[0.0, 0.5, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(5, 5), // Adds a shadow for depth
              ),
            ],
          ),
        ),
      ),
    ],
  );
  // return Center(
  //   child: Container(
  //     width: 200,
  //     height: 200,
  //     decoration: BoxDecoration(
  //       shape: BoxShape.circle, // Makes the container circular
  //       gradient: RadialGradient(
  //         center: const Alignment(-0.35, -0.35), // Position of the light source
  //         radius: 0.8,
  //         colors: [
  //           Color(colours[0]), // Bright spot
  //           Color(colours[4]), // Mid-tone
  //           Colors.black, // Shadow
  //         ],
  //         stops: [0.0, 0.5, 1.0], // Transition points
  //       ),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.3),
  //           blurRadius: 15,
  //           offset: Offset(5, 5), // Adds a shadow for depth
  //         ),
  //       ],
  //     ),
  //   ),
  // );
}
