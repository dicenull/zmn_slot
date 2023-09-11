import 'dart:math' as math;

import 'package:app/feature_slot/slot_core.dart';
import 'package:app/feature_slot/slot_symbol.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class SlotManager extends Component with HasGameRef<SlotGame> {
  ValueNotifier<int> point = ValueNotifier(100);
  ValueNotifier<int> maxBet = ValueNotifier(3);
  ValueNotifier<SlotPhase> phase = ValueNotifier(SlotPhase.normal);

  SlotManager();

  void addPoint(SlotSymbol? symbol) {
    final winPoint = switch (symbol) {
      null => 0,
      _ => symbol.point,
    };

    point.value += winPoint;
  }

  void addZundaPoint() {
    point.value += 100;
  }

  bool playSlot() {
    if (point.value < maxBet.value) {
      return false;
    }

    point.value -= maxBet.value;
    _setPhase();
    return true;
  }

  void _setPhase() {
    if (gameRef.zundaManager.isActive) {
      return;
    }

    final val = math.Random().nextInt(216);

    phase.value = switch (val) {
      // 4: 5/216=2.3%でずんだもちモード
      (<= 4) => () {
          gameRef.zundaManager.setupRaffle();
          return SlotPhase.zunda;
        },
      _ => () {
          return SlotPhase.miss;
        },
    }();
  }
}

enum SlotPhase {
  normal,
  hiyoko,
  plum,
  cherry,
  replay,
  miss,
  zunda,
  atari,
  retry,
  voicevox,
}
