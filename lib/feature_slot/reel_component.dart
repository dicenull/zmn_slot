import 'dart:async';
import 'dart:ui';

import 'package:app/feature_slot/slot_core.dart';
import 'package:app/feature_slot/slot_symbol.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/palette.dart';

class ReelComponent extends PositionComponent with HasGameRef<SlotGame> {
  final List<SlotSymbol> _symbols;
  final double reelHeight;
  final double symbolSize;
  final List<_SymbolState> _reel;

  // state
  bool isRoll = false;

  bool onCheckStopCurrent = false;
  _SuberiState? _suberiState;
  double reelPosition = 0;
  int stopIndex = -1;
  ReelComponent(this._symbols, this.symbolSize)
      : _reel = <_SymbolState>[],
        reelHeight = symbolSize * _symbols.length {
    _symbols.asMap().forEach((y, symbol) {
      final image = switch (symbol) {
        SlotSymbol.zunda => Flame.images.fromCache('zunda.png'),
        SlotSymbol.mon => Flame.images.fromCache('mon.png'),
        SlotSymbol.nanoda => Flame.images.fromCache('nanoda.png'),
      };

      _reel.add(_SymbolState(
        sprite: Sprite(image),
        symbol: symbol,
      ));
    });
  }

  Vector2 get slotCenter => Vector2(0, reelHeight * .5);

  double calcHeight(int y) => (y * symbolSize + reelPosition) % reelHeight;

  @override
  FutureOr<void> onLoad() {
    print(_calcCenterIndex());
  }

  @override
  void render(Canvas canvas) {
    final reelRange = Rect.fromCenter(
      center: Offset(symbolSize, reelHeight + symbolSize) * .5 +
          position.toOffset(),
      width: symbolSize,
      height: symbolSize * 1.5,
    );
    final bgColor = BasicPalette.white.withAlpha(50);

    canvas.clipRect(reelRange);
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

  void roll() {
    isRoll = true;
  }

  void stopCurrent() {
    onCheckStopCurrent = true;
  }

  @override
  void update(double dt) {
    final amount = 800 * dt;

    if (isRoll) {
      reelPosition += amount;
      reelPosition %= reelHeight;

      if (onCheckStopCurrent) {
        _stopCurrent();
        onCheckStopCurrent = false;
      }

      final index = _calcCenterIndex();
      final diff = slotCenter.y - calcHeight(index);
      if (diff.abs() < amount) {
        if (_suberiState?.symbol == _reel[index].symbol) {
          isRoll = false;
          _suberiState = null;
          stopIndex = index;
          reelPosition = (reelPosition / 64).ceil() * gameRef.symbolSize;
        }
      }
    }

    super.update(dt);
  }

  List<SlotSymbol> visibleSymbols() {
    if (stopIndex == -1) return [];

    final top = (_reel.length + stopIndex - 1) % _reel.length;
    final center = stopIndex;
    final bottom = (stopIndex + 1) % _reel.length;

    return [
      _reel[top].symbol,
      _reel[center].symbol,
      _reel[bottom].symbol,
    ];
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

  void _stopCurrent() {
    if (!isRoll) return;

    final index = _calcCenterIndex();
    var symbol = _reel[index].symbol;
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
