import 'package:firebase_auth/firebase_auth.dart' // new
    hide
        EmailAuthProvider,
        PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    _init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  Future<void> _init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
      } else {
        _loggedIn = false;
      }
      notifyListeners();
    });
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }
}
