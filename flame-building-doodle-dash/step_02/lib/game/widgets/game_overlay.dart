// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show Platform;

import 'package:flame/game.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../doodle_dash.dart';
import 'widgets.dart';

class GameOverlay extends StatefulWidget {
  const GameOverlay(this.game, {super.key});

  final Game game;

  @override
  State<GameOverlay> createState() => GameOverlayState();
}

class GameOverlayState extends State<GameOverlay> {
  bool isPaused = false;
  // Mobile Support: Add isMobile boolean
  final bool isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned(
            top: 30,
            left: 30,
            child: ScoreDisplay(game: widget.game),
          ),
          Positioned(
            top: 30,
            right: 30,
            child: ElevatedButton(
              child: isPaused
                  ? const Icon(
                      Icons.play_arrow,
                      size: 48,
                    )
                  : const Icon(
                      Icons.pause,
                      size: 48,
                    ),
              onPressed: () {
                (widget.game as DoodleDash).togglePauseState();
                setState(
                  () {
                    isPaused = !isPaused;
                  },
                );
              },
            ),
          ),
          // Mobile Support: Add on-screen left & right directional buttons
          if (isMobile)
            Positioned(
              bottom: MediaQuery.of(context).size.height / 4,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TouchDetector(
                      widget: widget,
                      leftPadding: 24,
                      onTapDown: (details) {
                        (widget.game as DoodleDash).player.moveLeft();
                      },
                      onTapUp: (details) {
                        (widget.game as DoodleDash).player.resetDirection();
                      },
                      iconData: Icons.arrow_left,
                    ),
                    TouchDetector(
                      widget: widget,
                      leftPadding: 24,
                      onTapDown: (details) {
                        (widget.game as DoodleDash).player.moveRight();
                      },
                      onTapUp: (details) {
                        (widget.game as DoodleDash).player.resetDirection();
                      },
                      iconData: Icons.arrow_right,
                    )
                  ],
                ),
              ),
            ),

          if (isPaused)
            Positioned(
              top: MediaQuery.of(context).size.height / 2 - 72.0,
              right: MediaQuery.of(context).size.width / 2 - 72.0,
              child: const Icon(
                Icons.pause_circle,
                size: 144.0,
                color: Colors.black12,
              ),
            ),
        ],
      ),
    );
  }
}

class TouchDetector extends StatelessWidget {
  const TouchDetector(
      {super.key,
      required this.widget,
      required this.iconData,
      this.leftPadding,
      this.rightPadding,
      this.onTapUp,
      this.onTapDown});

  final GameOverlay widget;
  final double? leftPadding;
  final double? rightPadding;
  final IconData iconData;
  final void Function(TapDownDetails)? onTapDown;
  final void Function(TapUpDetails)? onTapUp;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(left: leftPadding ?? 0.0, right: rightPadding ?? 0.0),
      child: GestureDetector(
        onTapDown: onTapDown,
        onTapUp: onTapUp,
        child: Material(
          color: Colors.transparent,
          elevation: 3.0,
          child: Icon(
            iconData,
            size: 64,
          ),
        ),
      ),
    );
  }
}
