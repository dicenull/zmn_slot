import 'dart:async';

import 'package:app/feature_slot/fever_mode_manager.dart';
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
  SlotSymbol? _hitSymbol;
  (SlotSymbol, SlotSymbol, SlotSymbol)? _meoshi;

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

  bool isHitSymbol(SlotPos sp, List<SlotSymbol> symbols) {
    final left = reels[0].visibleSymbols();
    final center = reels[1].visibleSymbols();
    final right = reels[2].visibleSymbols();

    print('$left $center $right $symbols');
    return switch (sp) {
      SlotPos.left => () {
          if (center == null || right == null) {
            return false;
          }

          return checkHitSymbol(symbols, center, right) != null;
        },
      SlotPos.center => () {
          if (left == null || right == null) {
            return false;
          }

          return checkHitSymbol(left, symbols, right) != null;
        },
      SlotPos.right => () {
          if (left == null || center == null) {
            return false;
          }

          return checkHitSymbol(left, center, symbols) != null;
        },
    }();
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
    inBet = true;
    _meoshi = null;
    _hitSymbol = null;

    for (var reel in reels) {
      reel.roll();
    }

    zundamon.current = switch (gameRef.slotManager.phase.value) {
      SlotPhase.miss => ZundamonState.idle,
      SlotPhase.zunda => ZundamonState.zunda,
      _ => ZundamonState.chance,
    };
    for (var button in buttons) {
      button.reset();
    }

    final _ = switch (gameRef.slotManager.phase.value) {
      SlotPhase.zunda => () {
          _hitSymbol = gameRef.zundaManager.updateNext();
          rollStream.add(SlotEvent.zunda);
        },
      SlotPhase.fever => () {
          final isFever = gameRef.feverManager.getChallenge();

          if (isFever) {
            rollStream.add(SlotEvent.fever);
            _meoshi = (SlotSymbol.zu, SlotSymbol.nn, SlotSymbol.da);
          } else {
            rollStream.add(SlotEvent.result);

            if (gameRef.feverManager.status == FeverStatus.retry) {
              final canRetry = gameRef.feverManager.challengeRetry();

              if (canRetry) {
                _hitSymbol = SlotSymbol.watermelon;
              }
            }
          }
        },
      SlotPhase.hiyoko => () {
          _hitSymbol = SlotSymbol.bell;
        },
      SlotPhase.replay => () {
          _hitSymbol = SlotSymbol.replay;
        },
      SlotPhase.plum => () {
          _hitSymbol = SlotSymbol.plum;
        },
      _ => () {
          rollStream.add(SlotEvent.roll);
        },
    }();
  }

  void stop(int index) {
    if (!reels[index].isRoll) return;

    // 0:最初, 1: 二つ目, 2:最後
    final count = reels.where((r) => !r.isRoll).length;

    (SlotSymbol, ReelPos)? suberi;
    final hit = _hitSymbol;
    if (hit != null) {
      suberi = (hit, ReelPos.values[index]);
    }

    final meoshi = _meoshi;
    SlotSymbol? reelCanStopSymbol;
    if (meoshi != null) {
      final (l, c, r) = meoshi;
      reelCanStopSymbol = [l, c, r][index];
    }

    print('onStop: $suberi, $reelCanStopSymbol');
    reels[index].stopCurrent(suberi, reelCanStopSymbol);
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

              if (l == SlotSymbol.watermelon) {
                rollStream.add(SlotEvent.smallBonus);
                Future.delayed(const Duration(milliseconds: 300), () {
                  FlameAudio.play('zundamon_atari.wav');
                });
              }

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

enum SlotPos {
  left,
  center,
  right,
}
