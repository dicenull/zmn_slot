import 'dart:async';

import 'package:app/feature_slot/reel_button_component.dart';
import 'package:app/feature_slot/reel_component.dart';
import 'package:app/feature_slot/slot_core.dart';
import 'package:app/feature_slot/slot_manager.dart';
import 'package:app/feature_slot/slot_symbol.dart';
import 'package:app/feature_slot/zudamon_component.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

class SlotComponent extends PositionComponent with HasGameRef<SlotGame> {
  final List<ReelComponent> reels;
  final List<ReelButtonComponent> buttons;

  late final ZundamonComponent zundamon;
  // state
  bool inBet = false;

  final textPaint = TextPaint(
    style: const TextStyle(
      fontSize: 30,
      color: Colors.white,
    ),
  );

  SlotComponent(this.reels)
      : buttons = List.generate(reels.length, (_) => ReelButtonComponent());

  ((SlotSymbol, SlotSymbol, SlotSymbol), (int, int, int))? checkHitSymbol(
      List<SlotSymbol> left, List<SlotSymbol> center, List<SlotSymbol> right) {
    final q = [
      (0, 1, 2), // 上から下斜め
      (2, 1, 0), // 下から上斜め
      (0, 0, 0), // 上段
      (1, 1, 1), // 中段
      (2, 2, 2), // 下段
    ];

    SlotSymbol? maxMatch;
    (int, int, int)? matchPos;
    for (var (x, y, z) in q) {
      final l = left[x];
      final c = center[y];
      final r = right[z];

      if (l == SlotSymbol.zu && c == SlotSymbol.nn && r == SlotSymbol.da) {
        return ((l, c, r), (x, y, z));
      }

      if (matchAll(l, c, r)) {
        if (maxMatch == null || maxMatch.point < l.point) {
          maxMatch = l;
          matchPos = (x, y, z);
        }
      }
    }

    if (maxMatch == null) return null;

    return ((maxMatch, maxMatch, maxMatch), matchPos!);
  }

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

    zundamon = ZundamonComponent()
      ..position = Vector2(gameRef.symbolSize * 2, 0)
      ..anchor = Anchor.center;

    buttons.asMap().forEach((x, button) {
      final size = gameRef.symbolSize * .7;
      button
        ..size = Vector2.all(size)
        ..position = Vector2((x - 1) * size * 1.2, gameRef.symbolSize * 2)
        ..anchor = Anchor.center
        ..onPressed = () {
          stop(x);
        };
    });

    add(zundamon);
    addAll(buttons);
  }

  void roll() {
    if (inBet) return;

    final canPlay = gameRef.slotManager.playSlot();
    if (!canPlay) {
      return;
    }

    rollStream.add(SlotEvent.roll);
    for (var reel in reels) {
      reel.roll();
    }
    zundamon.current = ZundamonState.idle;
    for (var button in buttons) {
      button.reset();
    }
    inBet = true;
  }

  void stop(int index) {
    if (!reels[index].isRoll) return;

    // 0:最初, 1: 二つ目, 2:最後
    final count = reels.map((r) => r.isRoll).length;
    final suberi = switch (gameRef.slotManager.phase.value) {
      SlotPhase.replay => (SlotSymbol.replay, ReelPos.center),
      SlotPhase.plum => (SlotSymbol.plum, ReelPos.center),
      _ => null,
    };

    reels[index].stopCurrent(suberi);
    buttons[index].push();
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
          inBet = false;
          final hitSymbol = checkHitSymbol(left, center, right);

          if (hitSymbol != null) {
            final ((l, c, r), (x, y, z)) = hitSymbol;

            if (l == SlotSymbol.zu &&
                c == SlotSymbol.nn &&
                r == SlotSymbol.da) {
              Future.delayed(const Duration(milliseconds: 1000), () {
                FlameAudio.play('zundamon_atari.wav');
              });

              gameRef.slotManager.addZundaPoint();
              rollStream.add(SlotEvent.bigBonus);
            } else {
              gameRef.slotManager.addPoint(l);
              rollStream.add(SlotEvent.smallBonus);

              reels[0].hit(x);
              reels[1].hit(y);
              reels[2].hit(z);

              zundamon.current = ZundamonState.hit;
            }
          }
        }
      }
    }

    super.update(dt);
  }
}
