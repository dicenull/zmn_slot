import 'dart:ui';

import 'package:app/feature_slot/slot_core.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/palette.dart';

class ReelButtonComponent extends PositionComponent
    with TapCallbacks, HasGameRef<SlotGame> {
  var pressed = true;
  final defaultColor = BasicPalette.green;
  final pressColor = BasicPalette.darkGreen;

  VoidCallback? onPressed;

  ReelButtonComponent({this.onPressed});

  @override
  void onTapDown(TapDownEvent event) {
    push();
  }

  void push() {
    if (!pressed) {
      pressed = true;
      onPressed?.call();
    }
  }

  @override
  void render(Canvas canvas) {
    final painter = pressed ? pressColor : defaultColor;

    final area = Rect.fromCenter(
      center: (size * .5).toOffset(),
      width: width,
      height: height * .7,
    );

    canvas.drawOval(area, painter.paint());
    canvas.drawOval(
      area,
      BasicPalette.white.paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    super.render(canvas);
  }

  void reset() => pressed = false;
}
