import 'dart:async';

import 'package:app/feature_slot/reel_component.dart';
import 'package:app/feature_slot/slot_core.dart';
import 'package:flame/components.dart';

class SlotComponent extends PositionComponent with HasGameRef<SlotGame> {
  final List<ReelComponent> reels;

  // state
  bool inBet = false;

  SlotComponent(this.reels);

  bool matchAll<T>(T a, T b, T c) => a == b && b == c;

  @override
  FutureOr<void> onLoad() {
    addAll(reels);
  }

  void roll() {
    if (inBet) return;

    final canPlay = gameRef.playSlot();
    if (!canPlay) {
      return;
    }

    for (var reel in reels) {
      reel.roll();
    }
    inBet = true;
  }

  void stop(int index) {
    if (!reels[index].isRoll) return;

    reels[index].stopCurrent();
  }

  @override
  void update(double dt) {
    reels.asMap().forEach((x, reel) {
      final leftCenterPos = (gameRef.canvasSize.x / 2) -
          (reels.length - 1) * .5 * gameRef.symbolSize;
      final padding = (x - 1) * gameRef.symbolSize;

      reel.position = Vector2(leftCenterPos + padding, 15);
    });

    if (inBet) {
      if (reels.every((reel) => !reel.isRoll)) {
        final table = reels.map((reel) => reel.visibleSymbols()).toList();

        if (table.every((symbols) => symbols.isNotEmpty)) {
          // 同じ絵柄で揃った
          if (matchAll(
            table[0][1],
            table[1][1],
            table[2][1],
          )) {
            gameRef.addPoint();
          }

          inBet = false;
        }
      }
    }

    super.update(dt);
  }
}
