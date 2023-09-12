import 'dart:async';

import 'package:app/feature_slot/slot_core.dart';
import 'package:app/feature_slot/slot_symbol.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/palette.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

const isDebug = false;

typedef SlotHitCallback = bool Function(List<SlotSymbol>);

class ReelComponent extends PositionComponent
    with HasGameRef<SlotGame>, HasPaint {
  final List<SlotSymbol> _symbols;
  final double reelHeight;
  final double symbolSize;
  final List<_SymbolState> _reel;
  final SlotHitCallback onHit;

  // state
  bool isRoll = false;
  int stopIndex = -1;
  final speed = 1000;

  var reelClipRange = Rect.zero;
  bool isStopReady = false;

  double reelPosition = 0;
  TextPaint textPaint = TextPaint(
    style: const TextStyle(fontSize: 16.0, color: Colors.blue),
  );

  (SlotSymbol, ReelPos)? _suberi;
  SlotSymbol? _meoshi;

  final visibleCount = 4;

  ReelComponent(this._symbols, this.symbolSize, this.onHit)
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
        SlotSymbol.replay => Flame.images.fromCache('replay_zundamon.png'),
        SlotSymbol.bell => Flame.images.fromCache('bell_ahiru.png'),
        SlotSymbol.plum => Flame.images.fromCache('plum_edamame.png'),
      };

      final spriteComponent = SpriteComponent(
        sprite: Sprite(image),
        size: Vector2.all(symbolSize),
        anchor: Anchor.topLeft,
      );
      add(spriteComponent);
      _reel.add(_SymbolState(
        sprite: spriteComponent,
        symbol: symbol,
      ));
    });
  }

  Effect get hitEffect => ColorEffect(
        const Color(0xFFFFFFFF),
        const Offset(0.0, 0.5),
        EffectController(
          duration: 1,
          curve: Curves.easeOutExpo,
          reverseDuration: .5,
        ),
      );

  int get length => _symbols.length;

  Offset get margin => (_reel.length % 2 != visibleCount % 2)
      ? Offset.zero
      : Offset(0, symbolSize * .5);
  Vector2 get reelCenter =>
      Vector2(symbolSize, visibleReelHeight) * .5 - margin.toVector2();
  double get visibleReelHeight => symbolSize * visibleCount;
  double calcDrawHeight(int y) =>
      (symbolSize * y + reelPosition) % reelHeight - reelHeight * .5;

  void hit(int pos) {
    final hitIndex = (pos - 1 + stopIndex + _reel.length) % _reel.length;

    _reel[hitIndex].sprite.add(hitEffect);
  }

  @override
  FutureOr<void> onLoad() {
    reelClipRange = Rect.fromCenter(
      center: reelCenter.toOffset(),
      width: symbolSize,
      height: visibleReelHeight,
    );

    final shadowComponent = _ShadowComponent(reelClipRange);
    add(shadowComponent);
  }

  @override
  void render(Canvas canvas) {
    final bgColor = BasicPalette.white.withAlpha(100);
    final borderColor = BasicPalette.white.paint()
      ..style = PaintingStyle.stroke;

    if (!isDebug) {
      canvas.clipRect(reelClipRange);
    }

    canvas.drawRect(reelClipRange, bgColor.paint());
    canvas.drawRect(reelClipRange, borderColor);

    if (isDebug) {
      _reel.asMap().forEach((y, state) {
        final p = state.sprite.position;
        textPaint.render(canvas, y.toString(), p);
        canvas.drawRect(
            Rect.fromPoints(p.toOffset(), Offset(symbolSize, symbolSize)),
            BasicPalette.green.paint()..style = PaintingStyle.stroke);
      });
      canvas.drawCircle(reelCenter.toOffset(), 20, bgColor.paint());

      final centerIndex = _calcCenterIndex();
      final symbolCenterHeight = calcDrawHeight(centerIndex) + symbolSize * .5;

      canvas.drawCircle(Offset(0, symbolCenterHeight), 5, bgColor.paint());
    }
  }

  void roll() {
    _suberi = null;
    isRoll = true;
    stopIndex = -1;
  }

  void stopCurrent((SlotSymbol, ReelPos)? suberi, SlotSymbol? meoshi) {
    _suberi = suberi;
    _meoshi = meoshi;
    isStopReady = true;
  }

  @override
  void update(double dt) {
    final amount = speed * dt;

    if (isRoll) {
      reelPosition += amount;
      reelPosition %= reelHeight;

      if (isStopReady) {
        final centerIndex = _calcCenterIndex();
        final symbolCenterHeight =
            calcDrawHeight(centerIndex) + symbolSize * .5;
        final diff = reelCenter.y - symbolCenterHeight;
        final (t, c, b) = _indexList(centerIndex);

        if (diff.abs() <= amount * 1.5) {
          final suberi = _suberi;
          if (suberi != null) {
            final (symbol, pos) = suberi;
            final index = switch (pos) {
              ReelPos.top => t,
              ReelPos.center => c,
              ReelPos.bottom => b
            };

            if (_reel[index].symbol == symbol) {
              _onStop(centerIndex);
            }
          } else if (_meoshi != null) {
            // TODO: 目押し中はなんでも当たる
            _onStop(centerIndex);
          } else {
            final hitSymbol =
                onHit([_reel[t].symbol, _reel[c].symbol, _reel[b].symbol]);

            if (!hitSymbol) {
              _onStop(centerIndex);
            } else {
              print('suberi');
            }
          }
        }
      }
    }

    _reel.asMap().forEach((y, state) {
      state.sprite.position = Vector2(0, calcDrawHeight(y));
    });

    super.update(dt);
  }

  List<SlotSymbol>? visibleSymbols() {
    if (stopIndex == -1) return null;

    final (top, center, bottom) = _indexList(stopIndex);

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
      final diff = reelCenter.y - calcDrawHeight(i);
      if (diff > 0 && minDiff > diff) {
        minDiff = diff;
        index = i;
      }
    });

    return index;
  }

  (int top, int center, int bottom) _indexList(int origin) {
    final len = _reel.length;

    final top = (len + origin - 1) % len;
    final center = origin;
    final bottom = (origin + 1) % len;
    return (top, center, bottom);
  }

  void _onStop(int realStopIndex) {
    isRoll = false;
    isStopReady = false;
    stopIndex = realStopIndex;

    reelPosition = (_reel.length / 2 + 1 - realStopIndex) * symbolSize;

    final sfx = switch (visibleSymbols()?[1]) {
      SlotSymbol.zu => 'zundamon_zunda.wav',
      SlotSymbol.nn => 'zundamon_mon.wav',
      SlotSymbol.da => 'zundamon_nanoda.wav',
      null || _ => '',
    };
    if (sfx.isNotEmpty) FlameAudio.play(sfx);
  }
}

enum ReelPos { top, center, bottom }

class _ShadowComponent extends PositionComponent {
  final Rect clipRange;
  late final Shader shader;

  _ShadowComponent(this.clipRange);

  @override
  FutureOr<void> onLoad() {
    shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [
          0,
          .1,
          .9,
          1.0
        ],
        colors: [
          Colors.black,
          Color.fromRGBO(0, 0, 0, 0),
          Color.fromRGBO(0, 0, 0, 0),
          Colors.black,
        ]).createShader(clipRange);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(clipRange, Paint()..shader = shader);
  }
}

class _SymbolState {
  final SpriteComponent sprite;
  final SlotSymbol symbol;

  _SymbolState({required this.sprite, required this.symbol});
}
