import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class Seed {
  int iSeed; //image seed
  int xSeed; //x coordinate seed
  int ySeed; //y coordinate seed
  Seed({required this.iSeed, required this.xSeed, required this.ySeed});
}

Point getPoint(
    {required int height,
    required int width,
    required int radius,
    required int factor,
    required int xSeed,
    required int ySeed}) {
  int x = randDim(width, radius * factor, xSeed);
  int y = randDim(height, radius * factor, ySeed);
  Point p = Point(x, y);
  return p;
}

/// dim = is the dimension [height or width], rad = is the radius
int randDim(int dim, int rad, int seed) {
  int min = rad;
  int max = dim - rad;

  //print("dim = $dim, rad = $rad, min = $min, max = $max");
  var rnd = Random(seed);
  return min + rnd.nextInt(max - min);
}

/// dim = is the dimension [height or width], rad = is the radius
int randBetwen(int min, int max, int seed) {
  var rnd = Random(seed);
  return min + rnd.nextInt(max - min);
}

Seed getSeed(String address) {
  var hashBytes = utf8.encode(address);
  var hash = sha256.convert(hashBytes);
  var buff = ByteData.view(Uint8List.fromList(hash.bytes).buffer);
  int iSeed = buff.getInt64(0);
  int xSeed = buff.getInt64(8);
  int ySeed = buff.getInt64(16);
  return Seed(iSeed: iSeed, xSeed: xSeed, ySeed: ySeed);
}
