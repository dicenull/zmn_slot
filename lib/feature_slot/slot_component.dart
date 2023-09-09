import 'dart:async';
import 'dart:math' as math;

import 'package:app/feature_slot/reel_component.dart';
import 'package:app/feature_slot/slot_core.dart';
import 'package:app/feature_slot/slot_symbol.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

class SlotComponent extends PositionComponent with HasGameRef<SlotGame> {
  final List<ReelComponent> reels;

  // state
  bool inBet = false;

  final textPaint = TextPaint(
    style: const TextStyle(
      fontSize: 30,
      color: Colors.white,
    ),
  );

  SlotComponent(this.reels);

  bool matchAll<T>(T a, T b, T c) => a == b && b == c;

  @override
  FutureOr<void> onLoad() {
    addAll(reels);

    reels.asMap().forEach((x, reel) {
      final padding = (x - 1) * gameRef.symbolSize;

      reel.position = Vector2(
        padding - gameRef.symbolSize * .5,
        -reel.visibleReelHeight * .5,
      );
    });
  }

  void roll() {
    if (inBet) return;

    final canPlay = gameRef.playSlot();
    if (!canPlay) {
      return;
    }

    rollStream.add(SlotEvent.roll);
    for (var reel in reels) {
      // どこに止まるかを確定させる
      final index = math.Random().nextInt(reel.length);
      reel.roll(index);
    }
    inBet = true;
  }

  void stop(int index) {
    if (!reels[index].isRoll) return;

    reels[index].stopCurrent();
  }

  @override
  void update(double dt) {
    if (inBet) {
      if (reels.every((reel) => !reel.isRoll)) {
        final left = reels[0].visibleSymbols();
        final center = reels[1].visibleSymbols();
        final right = reels[2].visibleSymbols();
        print('$left');
        print('$center');
        print('$right');

        if (left != null && center != null && right != null) {
          final q = [
            (0, 1, 2), // 上から下斜め
            (2, 1, 0), // 下から上斜め
            (0, 0, 0), // 上段
            (1, 1, 1), // 中段
            (2, 2, 2), // 下段
          ];

          for (var (x, y, z) in q) {
            final l = left[x];
            final c = center[y];
            final r = right[z];

            if (l == SlotSymbol.zu &&
                c == SlotSymbol.nn &&
                r == SlotSymbol.da) {
              Future.delayed(const Duration(milliseconds: 1000), () {
                FlameAudio.play('zundamon_atari.wav');
              });

              gameRef.addZundaPoint();
              rollStream.add(SlotEvent.bigBonus);
            }

            if (matchAll(l, c, r)) {
              print("$l, $c, $r");

              gameRef.addPoint(l);
              rollStream.add(SlotEvent.smallBonus);
            }
          }

          inBet = false;
        }
      }
    }

    super.update(dt);
  }
}
