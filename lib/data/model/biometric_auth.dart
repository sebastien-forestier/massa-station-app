// // Project imports:
// import 'package:mug/service/local_storage.dart';
// import 'package:mug/shared/encryption/phrase_handler.dart';

// class BiometricAuth {
//   static const String _secureBiometricAuthKey = "_secureBiometricAuthKey";

//   static Future<String> get authKey async => await LocalStorage.getString(_secureBiometricAuthKey) ?? '';

//   static Future<void> setAuthKey() async => await LocalStorage.setSecureString(
//         _secureBiometricAuthKey,
//         PhraseHandler.getPass,
//       );

//   static Future<void> disable() async {
//     await LocalStorage.setIsBiometricAuthEnabled(false);
//     // Overwrite
//     await LocalStorage.setSecureString(
//       _secureBiometricAuthKey,
//       "BiometricAuthDisabled",
//     );
//     await LocalStorage.delete(_secureBiometricAuthKey);
//   }

//   static Future<void> enable() async {
//     await LocalStorage.setIsBiometricAuthEnabled(true);
//     await setAuthKey();
//   }
// }
