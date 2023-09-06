import 'package:app/feature_slot/slot_core.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ずんだもんスロット'),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              width: 300,
              height: 300,
              child: GameWidget(
                game: SlotGame(),
              ),
            ),
            const Text(
              'スタート: スペースキー ドラッグ',
              style: TextStyle(fontSize: 32),
            ),
            const Text(
              'ストップ: 1,2,3キー タップ',
              style: TextStyle(fontSize: 32),
            ),
          ],
        ),
      ),
    );
  }
}
