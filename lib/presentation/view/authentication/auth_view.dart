// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:mug/presentation/view/authentication/login_view.dart';
import 'package:mug/presentation/view/authentication/set_passphrase_view.dart';
import 'package:mug/service/provider.dart';

class AuthView extends ConsumerWidget {
  //final StreamController<SessionState> sessionStateStream;
  final bool? isKeyboardFocused;

  const AuthView({super.key, /*required this.sessionStateStream,*/ this.isKeyboardFocused});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //print("In the Authview page....");

    //final AsyncValue<String> _passphrase = ref.read(localStorageServiceProvider).passphrase;
    final pass = ref.read(localStorageServiceProvider).passphrase;

    //final session = ref.read(localSessionTimeoutProvider.notifier).getSession();
    return FutureBuilder(
        future: pass,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            //print("pass phrase data: ${snapshot.data}");
            if (snapshot.data!.isNotEmpty) {
              return LoginView(
                //sessionStream: session,
                isKeyboardFocused: isKeyboardFocused,
              );
            } else {
              return SetPassphraseView(
                //sessionStream: session,
                isKeyboardFocused: isKeyboardFocused,
              );
            }
          }
          return const CircularProgressIndicator();
        });
  }
}
