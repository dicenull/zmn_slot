import 'dart:math';

import 'package:app/feature_slot/slot_core.dart';
import 'package:app/feature_slot/slot_symbol.dart';
import 'package:flame/components.dart';

class ZundamochiModeManager extends Component with HasGameRef<SlotGame> {
  static const modeLength = 8;

  var count = 0;
  var isHit = false;

  bool get isActive => (count > 0);

  void setupRaffle() {
    count = modeLength;
    isHit = (Random().nextInt(5) == 0);
  }

  SlotSymbol updateNext() {
    final smallHitSymbol =
        (Random().nextInt(2) == 0) ? SlotSymbol.plum : SlotSymbol.replay;

    count--;
    if (count == 0) {
      return (isHit) ? SlotSymbol.watermelon : smallHitSymbol;
    }

    return smallHitSymbol;
  }
}
