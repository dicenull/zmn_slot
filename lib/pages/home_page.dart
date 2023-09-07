import 'dart:math';

import 'package:app/feature_slot/slot_core.dart';
import 'package:app/gen/assets.gen.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              height: 300,
              child: GameWidget(
                game: SlotGame(),
              ),
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(32),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 7,
                      child: _Message(),
                    ),
                    Flexible(
                      flex: 3,
                      child: _Zundamon(),
                    ),
                  ],
                ),
              ),
            )
          ],
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
          color: Colors.grey[300],
          border: Border.all(color: Colors.grey)),
      constraints: const BoxConstraints(minHeight: 100),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: AutoSizeText(
          textState.value,
          style: const TextStyle(fontSize: 32),
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
      final subsc = rollStream.stream.listen((event) {
        if (event != SlotEvent.roll) return;

        final zundaList = Assets.images.zundamon.values;
        final index = Random().nextInt(zundaList.length);

        zundamonImage.value = zundaList[index];
      });

      return subsc.cancel;
    }, const []);

    return Container(
      constraints: const BoxConstraints(minWidth: 100, minHeight: 100),
      child: zundamonImage.value.image(),
    );
  }
}
