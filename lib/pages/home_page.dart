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
        title: const Text('Title'),
      ),
      body: Center(
        child: SizedBox(
          width: 600,
          height: 600,
          child: GameWidget(
            game: SlotGame(),
          ),
        ),
      ),
    );
  }
}
