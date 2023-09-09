import 'dart:async';

import 'package:app/feature_slot/reel_component.dart';
import 'package:app/feature_slot/slot_component.dart';
import 'package:app/feature_slot/slot_symbol.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final rollStream = StreamController<SlotEvent>.broadcast();

enum SlotEvent {
  roll,
  smallBonus,
  bigBonus,
}

class SlotGame extends FlameGame
    with VerticalDragDetector, TapDetector, KeyboardEvents {
  TextPaint textPaint = TextPaint(
    style: const TextStyle(
      fontSize: 50,
      color: Colors.white,
    ),
  );

  late final SlotComponent slot;
  final symbolSize = 64.0;
  int _point = 100;

  int _index = 0;

  void addPoint(int value) {
    _point += value;
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isKeyDown = event is RawKeyDownEvent;
    final isSpace = keysPressed.contains(LogicalKeyboardKey.space);

    if (isSpace && isKeyDown) {
      slot.roll();
      return KeyEventResult.handled;
    }

    final stopKeys = [
      LogicalKeyboardKey.digit1,
      LogicalKeyboardKey.digit2,
      LogicalKeyboardKey.digit3
    ];
    var press = false;
    for (var i = 0; i < slot.reels.length; i++) {
      final keyPressed = keysPressed.contains(stopKeys[i]);
      if (keyPressed && isKeyDown) {
        slot.stop(i);
        press = true;
      }
    }
    if (press) return KeyEventResult.handled;

    return KeyEventResult.ignored;
  }

  @override
  Future<void> onLoad() async {
    await Flame.images.loadAll([
      'seven_zu.png',
      'seven_nn.png',
      'seven_da.png',
      'bar_voicevox.png',
      'watermelon_zundamochi.png',
      'cherry_edamame.png',
      'replay_edamame.png',
      'bell_ahiru.png'
    ]);
    await FlameAudio.audioCache.loadAll([
      'zundamon_zun.wav',
      'zundamon_mon.wav',
      'zundamon_nanoda.wav',
      'zundamon_atari.wav'
    ]);

    slot = SlotComponent([
      ReelComponent(SlotSymbol.leftReel, symbolSize),
      ReelComponent(SlotSymbol.centerReel, symbolSize),
      ReelComponent(SlotSymbol.rightReel, symbolSize),
    ]);
    slot.position = canvasSize * .5;

    await add(slot);
  }

  @override
  void onTapDown(TapDownInfo info) {
    slot.stop(_index);
    _index = (_index + 1) % slot.reels.length;
  }

  @override
  void onVerticalDragEnd(DragEndInfo info) {
    slot.roll();
    _index = 0;
  }

  bool playSlot() {
    _point -= 1;
    if (_point < 0) {
      _point = 0;
      return false;
    }

    return true;
  }

  @override
  void render(Canvas canvas) {
    textPaint.render(canvas, _point.toString(), Vector2(0, 0));

    super.render(canvas);
  }
}
