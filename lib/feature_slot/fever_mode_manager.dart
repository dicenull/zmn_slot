import 'dart:math';

import 'package:app/feature_slot/slot_core.dart';
import 'package:flame/components.dart';

class FeverModeManager extends Component with HasGameRef<SlotGame> {
  var status = FeverStatus.disable;
  var rnd = Random();
  var isFirst = false;

  bool challengeRetry() {
    updateNextStatus();

    return (status == FeverStatus.enable);
  }

  bool getChallenge() {
    if (status != FeverStatus.enable) {
      return false;
    }

    if (isFirst) {
      isFirst = false;
      return true;
    }

    updateNextStatus();
    return (status == FeverStatus.enable);
  }

  void updateNextStatus() {
    status = switch (status) {
      FeverStatus.disable => FeverStatus.ready,
      FeverStatus.ready => _activate(),
      FeverStatus.enable => _challenge(),
      FeverStatus.retry => _retry(),
    };
  }

  FeverStatus _activate() {
    isFirst = true;
    return FeverStatus.enable;
  }

  FeverStatus _challenge() {
    final isFinish = rnd.nextInt(100) < 10;

    if (isFinish) {
      return FeverStatus.retry;
    } else {
      return FeverStatus.enable;
    }
  }

  FeverStatus _retry() {
    final canRestart = rnd.nextInt(100) < 5;

    if (canRestart) {
      return FeverStatus.enable;
    } else {
      return FeverStatus.disable;
    }
  }
}

enum FeverStatus {
  enable,
  disable,
  ready,
  retry,
}
