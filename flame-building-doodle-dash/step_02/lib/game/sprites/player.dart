// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import '../doodle_dash.dart';
// Core gameplay: Import sprites.dart
import 'sprites.dart';

enum PlayerState {
  left,
  right,
  center,
  rocket,
  nooglerCenter,
  nooglerLeft,
  nooglerRight
}

class Player extends SpriteGroupComponent<PlayerState>
    with HasGameRef<DoodleDash>, KeyboardHandler, CollisionCallbacks {
  Player({
    super.position,
    required this.character,
    this.jumpSpeed = 600,
  }) : super(
          size: Vector2(79, 109),
          anchor: Anchor.center,
          priority: 1,
        );

  int _hAxisInput = 0;
  final int movingLeftInput = -1;
  final int movingRightInput = 1;
  Vector2 _velocity = Vector2.zero();
  bool get isMovingDown => _velocity.y > 0;
  Character character;
  double jumpSpeed;
  // Core gameplay: Add _gravity property
  final double _gravity = 9;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Core gameplay: Add circle hitbox to Dash
    await add(CircleHitbox());
    // Add a Player to the game: loadCharacterSprites
    await _loadCharacterSprites();
    // Add a Player to the game: Default Dash onLoad to center state
    current = PlayerState.center;
  }

  @override
  void update(double dt) {
    // Add a Player to the game: Add game state check
    if (gameRef.gameManager.isIntro || gameRef.gameManager.isGameOver) return;
    // Add a Player to the game: Add calcualtion for Dash's horizontal velocity
    _velocity.x = _hAxisInput * jumpSpeed;
    final double dashHorizontalCenter = size.x / 2;

    // Add a Player to the game: Add infinite side boundaries logic
    if (position.x < dashHorizontalCenter) {
      position.x = gameRef.size.x - dashHorizontalCenter;
    }
    if (position.x > gameRef.size.x - (dashHorizontalCenter)) {
      position.x = dashHorizontalCenter;
    }

    // Core gameplay: Add gravity
    _velocity.y += _gravity;

    // Add a Player to the game: Calculate Dash's current position based on
    // her velocity over elapsed time since last update cycle
    position += _velocity * dt;

    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _hAxisInput = 0;

    // Add a Player to the game: Add keypress logic
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      moveLeft();
    }

    if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      moveRight();
    }

    if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      jump();
    }

    return true;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is EnemyPlatform && !isInvincible) {
      gameRef.onLose();
      return;
    }
    bool isCollidingVertically =
        (intersectionPoints.first.y - intersectionPoints.last.y).abs() < 5;

    if (isMovingDown && isCollidingVertically) {
      current = PlayerState.center;
      if (other is NormalPlatform) {
        jump();
        return;
      } else if (other is SpringBoard) {
        jump(specialJumpSpeed: jumpSpeed * 2);
        return;
      } else if (other is BrokenPlatform &&
          other.current == BrokenPlatformState.cracked) {
        jump();
        other.breakPlatform();
        return;
      }
    }

    if (!hasPowerUp && other is Rocket) {
      current = PlayerState.rocket;
      other.removeFromParent();
      jump(specialJumpSpeed: jumpSpeed * other.jumpSpeedMultiplier);
      return;
    } else if (!hasPowerUp && other is NooglerHat) {
      if (current == PlayerState.center) current = PlayerState.nooglerCenter;
      if (current == PlayerState.left) current = PlayerState.nooglerLeft;
      if (current == PlayerState.right) current = PlayerState.nooglerRight;
      other.removeFromParent();
      _removePowerupAfterTime(other.activeLengthInMS);
      jump(specialJumpSpeed: jumpSpeed * other.jumpSpeedMultiplier);
      return;
    }
  }

  void moveLeft() {
    // Add a Player to the game: Add logic for moving left
    _hAxisInput = 0;
    if (isWearingHat) {
      current = PlayerState.nooglerLeft;
    } else if (!hasPowerUp) {
      current = PlayerState.left;
    }
    _hAxisInput += movingLeftInput;
  }

  void moveRight() {
    // Add a Player to the game: Add logic for moving right
    _hAxisInput = 0;

    if (isWearingHat) {
      current = PlayerState.nooglerRight;
    } else if (!hasPowerUp) {
      current = PlayerState.right;
    }
    _hAxisInput += movingRightInput;
  }

  void resetDirection() {
    _hAxisInput = 0;
  }

  // Powerups: Add hasPowerup getter
  bool get hasPowerUp =>
      current == PlayerState.rocket ||
      current == PlayerState.nooglerLeft ||
      current == PlayerState.nooglerRight ||
      current == PlayerState.nooglerCenter;

  // Powerups: Add isInvincible getter
  bool get isInvincible => current == PlayerState.rocket;

  // Powerups: Add isWearingHat getter
  bool get isWearingHat =>
      current == PlayerState.nooglerLeft ||
      current == PlayerState.nooglerRight ||
      current == PlayerState.nooglerCenter;
  // Core gameplay: Override onCollision callback

  // Core gameplay: Add a jump method
  void jump({double? specialJumpSpeed}) {
    _velocity.y = specialJumpSpeed != null ? -specialJumpSpeed : -jumpSpeed;
  }

  void _removePowerupAfterTime(int ms) {
    Future.delayed(Duration(milliseconds: ms), () {
      current = PlayerState.center;
    });
  }

  void setJumpSpeed(double newJumpSpeed) {
    jumpSpeed = newJumpSpeed;
  }

  void reset() {
    _velocity = Vector2.zero();
    current = PlayerState.center;
  }

  void resetPosition() {
    position = Vector2(
      (gameRef.size.x - size.x) / 2,
      (gameRef.size.y - size.y) / 2,
    );
  }

  Future<void> _loadCharacterSprites() async {
    // Load & configure sprite assets
    final left = await gameRef.loadSprite('game/${character.name}_left.png');
    final right = await gameRef.loadSprite('game/${character.name}_right.png');
    final center =
        await gameRef.loadSprite('game/${character.name}_center.png');
    final rocket = await gameRef.loadSprite('game/rocket_4.png');
    final nooglerCenter =
        await gameRef.loadSprite('game/${character.name}_hat_center.png');
    final nooglerLeft =
        await gameRef.loadSprite('game/${character.name}_hat_left.png');
    final nooglerRight =
        await gameRef.loadSprite('game/${character.name}_hat_right.png');

    sprites = <PlayerState, Sprite>{
      PlayerState.left: left,
      PlayerState.right: right,
      PlayerState.center: center,
      PlayerState.rocket: rocket,
      PlayerState.nooglerCenter: nooglerCenter,
      PlayerState.nooglerLeft: nooglerLeft,
      PlayerState.nooglerRight: nooglerRight,
    };
  }
}
