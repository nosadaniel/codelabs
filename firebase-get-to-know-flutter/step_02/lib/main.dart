import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'src/screens/authentication.dart';
import 'src/state/application_state.dart';
import 'src/widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider<ApplicationState>(
    create: (context) => ApplicationState(),
    builder: ((context, child) => const App()),
  ));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomePage(),
        '/sign-in': (context) {
          return SignInScreen(
            actions: [
              ForgotPasswordAction((context, email) {
                Navigator.of(context)
                    .pushNamed('/forgot-password', arguments: {'email': email});
              }),
              AuthStateChangeAction((context, state) {
                if (state is SignedIn || state is UserCreated) {
                  User? user = (state is SignedIn)
                      ? state.user
                      : (state as UserCreated).credential.user;
                  if (user == null) {
                    return;
                  }
                  if (state is UserCreated) {
                    user.updateDisplayName(user.email!.split('@')[0]);
                  }
                  if (!user.emailVerified) {
                    user.sendEmailVerification();
                    SnackBar snackBar = const SnackBar(
                        content: Text(
                            'Please check your email to verify your email address'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                  Navigator.of(context).pushReplacementNamed('/home');
                }
              })
            ],
          );
        },
        '/forgot-password': (context) {
          final arguments = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return ForgotPasswordScreen(
            email: "${arguments['email']}",
            headerMaxExtent: 200,
          );
        },
        '/profile': (context) {
          return ProfileScreen(
            providers: const [],
            actions: [
              SignedOutAction((context) {
                Navigator.of(context).pushReplacementNamed('/home');
              })
            ],
          );
        }
      },
      title: 'Firebase Meetup',
      theme: ThemeData(
        buttonTheme: Theme.of(context).buttonTheme.copyWith(
              highlightColor: Colors.deepPurple,
            ),
        primarySwatch: Colors.deepPurple,
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(builder: (context, appState, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Firebase Meetup'),
        ),
        body: ListView(
          children: <Widget>[
            Image.asset('assets/codelab.png'),
            const SizedBox(height: 8),
            const IconAndDetail(Icons.calendar_today, 'October 30'),
            const IconAndDetail(Icons.location_city, 'San Francisco'),
            Consumer<ApplicationState>(builder: (context, appState, child) {
              return AuthFunc(
                  loggedIn: appState.loggedIn,
                  signOut: () {
                    appState.signOut();
                  });
            }),
            const Divider(
              height: 8,
              thickness: 1,
              indent: 8,
              endIndent: 8,
              color: Colors.grey,
            ),
            const Header("What we'll be doing"),
            const Paragraph(
              'Join us for a day full of Firebase Workshops and Pizza!',
            ),
          ],
        ),
      );
    });
  }
}
