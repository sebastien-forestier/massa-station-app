//inspired by safenote

// Dart imports:
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

// Package imports:
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

String generateRandString(int len) {
  var randomNumber = Random.secure(); // cryptographically secure number random
  return String.fromCharCodes(List.generate(len, (index) => randomNumber.nextInt(33) + 89));
}

String encryptAES(String plainText, String passphrase) {
  try {
    final salt = generateRandomNonZero(8);
    var keyndIV = deriveKeyAndIV(passphrase, salt);
    String randomString = generateRandString(8);
    final key = encrypt.Key(keyndIV.$1);
    final iv = encrypt.IV(keyndIV.$2);

    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: "PKCS7"));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    Uint8List encryptedBytesWithSalt =
        Uint8List.fromList(createUint8ListFromString(randomString) + salt + encrypted.bytes);
    return base64.encode(encryptedBytesWithSalt);
  } catch (error) {
    rethrow;
  }
}

String decryptAES(String encrypted, String passphrase) {
  try {
    Uint8List encryptedBytesWithSalt = base64.decode(encrypted);

    Uint8List encryptedBytes = encryptedBytesWithSalt.sublist(16, encryptedBytesWithSalt.length);
    final salt = encryptedBytesWithSalt.sublist(8, 16);
    var keyndIV = deriveKeyAndIV(passphrase, salt);
    final key = encrypt.Key(keyndIV.$1);
    final iv = encrypt.IV(keyndIV.$2);

    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: "PKCS7"));
    final decrypted = encrypter.decrypt64(base64.encode(encryptedBytes), iv: iv);
    return decrypted;
  } catch (error) {
    throw error;
  }
}

(Uint8List, Uint8List) deriveKeyAndIV(String passphrase, Uint8List salt) {
  var password = createUint8ListFromString(passphrase);
  Uint8List concatenatedHashes = Uint8List(0);
  Uint8List currentHash = Uint8List(0);
  bool enoughBytesForKey = false;
  Uint8List preHash = Uint8List(0);

  while (!enoughBytesForKey) {
    if (currentHash.isNotEmpty) {
      preHash = Uint8List.fromList(currentHash + password + salt);
    } else {
      preHash = Uint8List.fromList(password + salt);
    }
    currentHash = Uint8List.fromList(sha256.convert(preHash).bytes);
    concatenatedHashes = Uint8List.fromList(concatenatedHashes + currentHash);
    if (concatenatedHashes.length >= 48) enoughBytesForKey = true;
  }

  var keyBytes = concatenatedHashes.sublist(0, 32); //32 Byte key length => 256 bit key for AES-256
  var ivBytes = concatenatedHashes.sublist(32, 48);
  return (keyBytes, ivBytes);
}

Uint8List createUint8ListFromString(String s) {
  var ret = Uint8List(s.length);
  for (var i = 0; i < s.length; i++) {
    ret[i] = s.codeUnitAt(i);
  }
  return ret;
}

Uint8List generateRandomNonZero(int seedLength) {
  final random = Random.secure(); //cryptographically secure number random
  const int randomMax = 245;
  final Uint8List uint8list = Uint8List(seedLength);
  for (int i = 0; i < seedLength; i++) {
    uint8list[i] = random.nextInt(randomMax) + 1;
  }
  return uint8list;
}
