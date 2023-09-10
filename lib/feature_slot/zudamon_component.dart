import 'dart:async';

import 'package:app/feature_slot/slot_core.dart';
import 'package:flame/components.dart';

class ZundamonComponent extends SpriteGroupComponent<ZundamonState>
    with HasGameRef<SlotGame> {
  @override
  FutureOr<void> onLoad() async {
    final zundamons = [1, 2, 3, 4, 5, 6]
        .map((i) => Sprite.load('zundamon/zundamon000$i.png'))
        .toList();

    sprites = {
      ZundamonState.idle: await zundamons[0],
      ZundamonState.chance: await zundamons[1],
      ZundamonState.hit: await zundamons[2],
    };
    current = ZundamonState.idle;
    scale = Vector2.all(gameRef.symbolSize * 2 / sprite!.originalSize.y);
  }
}

enum ZundamonState {
  idle,
  chance,
  hit,
}
