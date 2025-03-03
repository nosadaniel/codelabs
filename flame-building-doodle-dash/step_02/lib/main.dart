// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'game/doodle_dash.dart';
import 'game/util/util.dart';
import 'game/widgets/widgets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doodle Dash',
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        colorScheme: lightColorScheme,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: darkColorScheme,
        textTheme: GoogleFonts.audiowideTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final Game game = DoodleDash();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: LayoutBuilder(builder: (context, constraints) {
        return Container(
          constraints: const BoxConstraints(
            maxWidth: 800,
            minWidth: 550,
          ),
          child: GameWidget(
            game: game,
            overlayBuilderMap: <String, Widget Function(BuildContext, Game)>{
              'gameOverlay': (context, game) => GameOverlay(game),
              'mainMenuOverlay': (context, game) => MainMenuOverlay(game),
              'gameOverOverlay': (context, game) => GameOverOverlay(game),
            },
          ),
        );
      }),
    );
  }
}
