import 'dart:math';

import 'package:app/feature_slot/slot_core.dart';
import 'package:app/gen/assets.gen.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _game = SlotGame();

class HomePage extends HookConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ずんだもんスロット'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(minHeight: 200, maxWidth: 700),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Flexible(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: _Message(),
                ),
              ),
              Flexible(
                flex: 2,
                child: SizedBox(
                  child: GameWidget(
                    game: _game,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Message extends HookConsumerWidget {
  const _Message();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const desc = 'スペースキーか、ドラッグでスタート。1,2,3キーか、タップでストップなのだ。';
    final textState = useState(desc);

    useEffect(() {
      final subsc = rollStream.stream.listen((event) {
        final nextText = switch (event) {
          SlotEvent.roll => desc,
          SlotEvent.zunda =>
            'ずんだもちを作るのだ！チャンスはあと${_game.zundaManager.count}回なのだ！',
          SlotEvent.smallBonus => 'そろったのだ！',
          SlotEvent.bigBonus => 'ずんだもんなのだ！！！',
        };

        textState.value = nextText;
      });

      return subsc.cancel;
    }, const []);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.background,
        border: Border.all(color: Theme.of(context).colorScheme.primary),
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: AutoSizeText(
          textState.value,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

class _Zundamon extends HookConsumerWidget {
  const _Zundamon();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zundamonImage = useState(Assets.images.zundamon.zundamon0001);

    useEffect(() {
      final zundaList = Assets.images.zundamon.values;

      Future.microtask(() async {
        for (var zunda in zundaList) {
          precacheImage(zunda.provider(), context);
        }
      });

      final subsc = rollStream.stream.listen((event) {
        if (event != SlotEvent.roll) return;

        final index = Random().nextInt(zundaList.length);

        zundamonImage.value = zundaList[index];
      });

      return subsc.cancel;
    }, const []);

    return zundamonImage.value.image();
  }
}
