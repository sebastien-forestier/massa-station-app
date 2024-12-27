// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_session_timeout/local_session_timeout.dart';

// Project imports:
import 'package:mug/app.dart';
import 'package:mug/presentation/provider/local_session_timeout_provider.dart';
import 'package:mug/routes/routes.dart';
import 'package:mug/service/local_storage_service.dart';
import 'package:mug/service/provider.dart';
import 'package:mug/presentation/widget/generic.dart';
import 'package:mug/presentation/widget/logout_alert.dart';

class Mug extends ConsumerWidget {
  Mug({super.key});

  final navigatorKey = GlobalKey<NavigatorState>();
  NavigatorState? get _navigator => navigatorKey.currentState;
  late StreamController<SessionState> sessionStateStream; // = StreamController<SessionState>();
  late int focusTimeout; // = LocalStorage.focusTimeout;
  late int inactivityTimeout; // = LocalStorage.inactivityTimeout;
  late LocalStorageService _storage;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _storage = ref.read(localStorageServiceProvider);
    focusTimeout = _storage.focusTimeout;
    inactivityTimeout = _storage.inactivityTimeout;
    print("focus timeout: $focusTimeout in seconds");
    print("innactivity timeout: $inactivityTimeout in seconds");
    //local session configuration
    final sessionConfig = SessionConfig(
      invalidateSessionForAppLostFocus: Duration(seconds: focusTimeout),
      invalidateSessionForUserInactivity: Duration(seconds: inactivityTimeout),
    );

    sessionConfig.stream.listen(sessionHandler);
    //  stop listening, as user will already be in auth page
    sessionStateStream = ref.read(localSessionTimeoutProvider); //.add(SessionState.stopListening);

    return SessionTimeoutManager(
      sessionConfig: sessionConfig,
      child: App(
        navigatorKey: navigatorKey,
      ),
    );
  }

  Future<void> sessionHandler(SessionTimeoutState timeoutEvent) async {
    // stop listening, as user will already be in auth page
    sessionStateStream.add(SessionState.stopListening);
    BuildContext context = navigatorKey.currentContext!;

    if (timeoutEvent == SessionTimeoutState.userInactivityTimeout && _storage.isInactivityTimeoutOn) {
      await onTimeOutDo(
        context: context,
        showPreLogoffAlert: true,
      );
      // Don't logout if user is active
    } else if (timeoutEvent == SessionTimeoutState.appFocusTimeout) {
      await onTimeOutDo(
        context: context,
        showPreLogoffAlert: false,
      );
    }
  }

  Future<void> onTimeOutDo({required BuildContext context, required bool showPreLogoffAlert}) async {
    print("timeout is executed...");
    // execute only if user is already logged
    // no need to logout and redirect to authwall if user is not loggedIN
    if (_storage.isUserActive) {
      bool? isUserActive;
      if (showPreLogoffAlert) isUserActive = await preInactivityLogOffAlert(context);
      if (isUserActive == null || showPreLogoffAlert == false) {
        // isUserActive == null => show him logout Msg
        // showPreLogoffAlert == false => i.e. triggered by appFocusTimeout
        logout(
          context: context,
          showLogoutMsg: true,
        );
      }
      if (isUserActive == false) {
        // isUserActive == false => user choose to logout, don't show msg
        logout(
          context: context,
          showLogoutMsg: false,
        );
      }
      //else user pressed cancel and is active
    }
    // User is already on authpage
  }

  Future<void> logout({
    required BuildContext context,
    required bool showLogoutMsg,
  }) async {
    print("logout is executed...");
    print("user login status: ${_storage.isUserActive}");

    _navigator?.pushNamedAndRemoveUntil(
      AuthRoutes.authWall,
      (Route<dynamic> route) => false,
      arguments: false,
    );

    if (showLogoutMsg) {
      showGenericDialog(
        context: context,
        icon: Icons.info_outline,
        message: "You were logged out due to extended inactivity. This is to protect your privacy.",
      );
    }
    //Session.logout();
    _storage.setLoginStatus(false);
    print("user login after deactivate: ${_storage.isUserActive}");
  }
}
