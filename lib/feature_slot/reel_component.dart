import 'package:app/feature_slot/slot_core.dart';
import 'package:app/feature_slot/slot_symbol.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/palette.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

class ReelComponent extends PositionComponent with HasGameRef<SlotGame> {
  final List<SlotSymbol> _symbols;
  final double reelHeight;
  final double symbolSize;
  final List<_SymbolState> _reel;

  // state
  bool isRoll = false;
  int stopIndex = -1;
  final speed = 800;

  bool onCheckStopCurrent = false;

  _SuberiState? _suberiState;
  double reelPosition = 0;
  ReelComponent(this._symbols, this.symbolSize)
      : _reel = <_SymbolState>[],
        reelHeight = symbolSize * _symbols.length {
    _symbols.asMap().forEach((y, symbol) {
      final image = switch (symbol) {
        SlotSymbol.zu => Flame.images.fromCache('seven_zu.png'),
        SlotSymbol.nn => Flame.images.fromCache('seven_nn.png'),
        SlotSymbol.da => Flame.images.fromCache('seven_da.png'),
        SlotSymbol.bar => Flame.images.fromCache('bar_voicevox.png'),
        SlotSymbol.watermelon =>
          Flame.images.fromCache('watermelon_zundamochi.png'),
        SlotSymbol.cherry => Flame.images.fromCache('cherry_edamame.png'),
        SlotSymbol.replay => Flame.images.fromCache('replay_edamame.png'),
        // TODO: Handle this case.
        SlotSymbol.bell => Flame.images.fromCache('bell_ahiru.png'),
      };

      _reel.add(_SymbolState(
        sprite: Sprite(image),
        symbol: symbol,
      ));
    });
  }
  int get length => _symbols.length;

  Vector2 get slotCenter => Vector2(0, reelHeight * .5);

  double calcHeight(int y) => (y * symbolSize + reelPosition) % reelHeight;

  @override
  void render(Canvas canvas) {
    final reelRange = Rect.fromCenter(
      center: Offset(symbolSize, reelHeight + symbolSize) * .5 +
          position.toOffset(),
      width: symbolSize,
      height: symbolSize * 1.5,
    );
    final bgColor = BasicPalette.white.withAlpha(50);

    // canvas.clipRect(reelRange);
    canvas.drawRect(reelRange, bgColor.paint());

    _reel.asMap().forEach((y, state) {
      final p = Vector2(0, calcHeight(y));

      state.sprite.render(
        canvas,
        size: Vector2(symbolSize, symbolSize),
        position: p + position,
        anchor: Anchor.topLeft,
      );
    });
  }

  void roll(int index) {
    stopIndex = index;
    isRoll = true;
  }

  void stopCurrent() {
    onCheckStopCurrent = true;
  }

  @override
  void update(double dt) {
    final amount = speed * dt;

    if (isRoll) {
      reelPosition += amount;
      reelPosition %= reelHeight;

      if (onCheckStopCurrent) {
        _stopCurrent();
        onCheckStopCurrent = false;
      }

      final diff = slotCenter.y - calcHeight(stopIndex);
      if (diff.abs() < amount) {
        if (_suberiState?.symbol == _reel[stopIndex].symbol) {
          _onStop();
        }
      }
    }

    super.update(dt);
  }

  SlotSymbol? visibleSymbol() {
    if (stopIndex == -1) return null;

    final center = stopIndex;
    return _reel[center].symbol;
  }

  int _calcCenterIndex() {
    int index = 0;
    var minDiff = gameRef.canvasSize.y;

    // 最も画面の中心に近いシンボルを探す
    _reel.asMap().forEach((i, state) {
      final diff = slotCenter.y - calcHeight(i);
      if (diff > 0 && minDiff > diff) {
        minDiff = diff;
        index = i;
      }
    });

    return index;
  }

  void _onStop() {
    isRoll = false;
    _suberiState = null;
    reelPosition = (reelPosition / symbolSize).ceil() * symbolSize;

    final sfx = switch (visibleSymbol()) {
      SlotSymbol.zu => 'zundamon_zunda.wav',
      SlotSymbol.nn => 'zundamon_mon.wav',
      SlotSymbol.da => 'zundamon_nanoda.wav',
      null || _ => '',
    };
    if (sfx.isNotEmpty) FlameAudio.play(sfx);
  }

  void _stopCurrent() {
    if (!isRoll) return;

    var symbol = _reel[stopIndex].symbol;
    _suberiState = _SuberiState(symbol, 1);
  }
}

/// ピッタリ中央で止める滑りを入れるための状態
class _SuberiState {
  final SlotSymbol symbol;
  final int height;

  _SuberiState(this.symbol, this.height);
}

class _SymbolState {
  final Sprite sprite;
  final SlotSymbol symbol;

  _SymbolState({required this.sprite, required this.symbol});
}
