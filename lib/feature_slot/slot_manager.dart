import 'package:app/feature_slot/slot_core.dart';
import 'package:app/feature_slot/slot_symbol.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class SlotManager extends Component with HasGameRef<SlotGame> {
  ValueNotifier<int> point = ValueNotifier(100);
  ValueNotifier<int> maxBet = ValueNotifier(3);

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
    return true;
  }
}
