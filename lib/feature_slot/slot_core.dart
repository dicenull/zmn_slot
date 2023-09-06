import 'package:app/feature_slot/reel_component.dart';
import 'package:app/feature_slot/slot_component.dart';
import 'package:app/feature_slot/slot_symbol.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SlotGame extends FlameGame
    with VerticalDragDetector, TapDetector, KeyboardEvents {
  static const List<SlotSymbol> leftReel = [
    SlotSymbol.zunda,
    SlotSymbol.mon,
    SlotSymbol.nanoda,
    SlotSymbol.zunda,
    SlotSymbol.mon,
    SlotSymbol.nanoda,
  ];

  static const List<SlotSymbol> centerReel = [
    SlotSymbol.mon,
    SlotSymbol.nanoda,
    SlotSymbol.zunda,
    SlotSymbol.mon,
    SlotSymbol.nanoda,
    SlotSymbol.zunda,
  ];

  static const List<SlotSymbol> rightReel = [
    SlotSymbol.nanoda,
    SlotSymbol.zunda,
    SlotSymbol.mon,
    SlotSymbol.nanoda,
    SlotSymbol.zunda,
    SlotSymbol.mon,
  ];

  TextPaint textPaint = TextPaint(
    style: const TextStyle(
      fontSize: 100,
      color: Colors.white,
    ),
  );

  late final SlotComponent slot;
  final symbolSize = 64.0;
  int _point = 100;

  int _index = 0;

  void addPoint() {
    _point += 10;
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
      LogicalKeyboardKey.keyA,
      LogicalKeyboardKey.keyS,
      LogicalKeyboardKey.keyD
    ];
    for (var i = 0; i < slot.reels.length; i++) {
      final keyPressed = keysPressed.contains(stopKeys[i]);
      if (keyPressed && isKeyDown) {
        slot.stop(i);
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  Future<void> onLoad() async {
    await Flame.images.loadAll(['zunda.png', 'mon.png', 'nanoda.png']);

    slot = SlotComponent([
      ReelComponent(leftReel, symbolSize),
      ReelComponent(centerReel, symbolSize),
      ReelComponent(rightReel, symbolSize),
    ]);

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
    _point -= 3;
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
