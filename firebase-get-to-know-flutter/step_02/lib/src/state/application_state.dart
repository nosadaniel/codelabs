import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' // new
    hide
        EmailAuthProvider,
        PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import '../model/guest_book_message.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    _init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;
  StreamSubscription<QuerySnapshot>? _guestBookSubscription;
  StreamSubscription<DocumentSnapshot>? _attendingSubscription;

  final List<GuestBookMessage> _guestBookMessages = [];
  List<GuestBookMessage> get guestBookMessages => _guestBookMessages;

  Attending _attending = Attending.unknown;
  int _attendees = 0;

  int get attendees => _attendees;
  Attending get attending => _attending;

  Future<void> _init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    ///select provider
    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    ///count number of attendees by listening
    FirebaseFirestore.instance
        .collection('attendees')
        .where('attending', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      _attendees = snapshot.docs.length;
      //update ui
      notifyListeners();
    });

    ///listen messages in guestbook collection
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
        _guestBookSubscription = FirebaseFirestore.instance
            .collection('guestBook')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .listen((snapshot) {
          //clear exist data
          _guestBookMessages.clear();
          //add new data
          for (final doc in snapshot.docs) {
            _guestBookMessages.add(GuestBookMessage(
                name: "${doc.data()['name']}",
                message: "${doc.data()['text']}"));
          }
          //update ui messages
          notifyListeners();
        });

        ///listen to attending subscription
        _attendingSubscription = FirebaseFirestore.instance
            .collection('attendees')
            .doc(user.uid)
            .snapshots()
            .listen((snapshot) {
          if (snapshot.data() != null) {
            if (snapshot.data()!['attending'] as bool) {
              _attending = Attending.yes;
            } else {
              _attending = Attending.no;
            }
          } else {
            _attending = Attending.unknown;
          }
          //update ui for attending object
          notifyListeners();
        });
      } else {
        _loggedIn = false;
        _guestBookMessages.clear();
        _guestBookSubscription!.cancel();
        _attendingSubscription!.cancel();
      }
      //update login
      notifyListeners();
    });
  }

  ///logout
  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  /// add new message
  Future<DocumentReference> addMessageToGuestBook(String message) async {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }
    return FirebaseFirestore.instance
        .collection('guestBook')
        .add(<String, dynamic>{
      'text': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'name': FirebaseAuth.instance.currentUser!.displayName,
      'userId': FirebaseAuth.instance.currentUser!.uid,
    });
  }

  ///indicate you are coming
  set setAttending(Attending attending) {
    final DocumentReference userDoc = FirebaseFirestore.instance
        .collection('attendees')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    if (attending == Attending.yes) {
      userDoc.set(<String, dynamic>{'attending': true});
    } else {
      userDoc.set(<String, dynamic>{'attending': false});
    }
  }
}

enum Attending { yes, no, unknown }
