// // Dart imports:
// import 'dart:async';

// // Package imports:
// import 'package:local_session_timeout/local_session_timeout.dart';

// // Project imports:
// import 'package:mug/service/local_storage.dart';
// import 'package:mug/shared/encryption/phrase_handler.dart';
// import 'package:mug/shared/models/biometric_auth.dart';

// // Project imports:
// //import 'package:safenotes/data/preference_and_config.dart';
// //import 'package:safenotes/models/biometric_auth.dart';

// class Session {
//   static login(String passphrase) {
//     PhraseHandler.initPass(passphrase);
//   }

//   static logout() {
//     PhraseHandler.destroy();
//   }

//   static setOrChangePassphrase(String passphrase) {
//     LocalStorage.setPassphrase((passphrase));
//     PhraseHandler.initPass(passphrase);
//     if (LocalStorage.isBiometricAuthEnabled) BiometricAuth.setAuthKey();
//   }
// }

// class SessionArguments {
//   final StreamController<SessionState> sessionStream;
//   final bool? isKeyboardFocused;

//   SessionArguments({
//     required this.sessionStream,
//     this.isKeyboardFocused,
//   });
// }
