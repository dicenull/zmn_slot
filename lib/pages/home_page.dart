import 'package:app/gen/assets.gen.dart';
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Assets.images.zunda.image(width: 64, height: 64),
            Assets.images.mon.image(width: 64, height: 64),
            Assets.images.nanoda.image(width: 64, height: 64),
          ],
        ),
      ),
    );
  }
}
