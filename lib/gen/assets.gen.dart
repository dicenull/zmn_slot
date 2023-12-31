/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsAudioGen {
  const $AssetsAudioGen();

  /// File path: assets/audio/zundamon_atari.wav
  String get zundamonAtari => 'assets/audio/zundamon_atari.wav';

  /// File path: assets/audio/zundamon_mon.wav
  String get zundamonMon => 'assets/audio/zundamon_mon.wav';

  /// File path: assets/audio/zundamon_nanoda.wav
  String get zundamonNanoda => 'assets/audio/zundamon_nanoda.wav';

  /// File path: assets/audio/zundamon_reach.wav
  String get zundamonReach => 'assets/audio/zundamon_reach.wav';

  /// File path: assets/audio/zundamon_zunda.wav
  String get zundamonZunda => 'assets/audio/zundamon_zunda.wav';

  /// List of all assets
  List<String> get values => [
        zundamonAtari,
        zundamonMon,
        zundamonNanoda,
        zundamonReach,
        zundamonZunda
      ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/bar_voicevox.png
  AssetGenImage get barVoicevox =>
      const AssetGenImage('assets/images/bar_voicevox.png');

  /// File path: assets/images/bell_ahiru.png
  AssetGenImage get bellAhiru =>
      const AssetGenImage('assets/images/bell_ahiru.png');

  /// File path: assets/images/cherry_edamame.png
  AssetGenImage get cherryEdamame =>
      const AssetGenImage('assets/images/cherry_edamame.png');

  /// File path: assets/images/mon.png
  AssetGenImage get mon => const AssetGenImage('assets/images/mon.png');

  /// File path: assets/images/nanoda.png
  AssetGenImage get nanoda => const AssetGenImage('assets/images/nanoda.png');

  /// File path: assets/images/replay_edamame.png
  AssetGenImage get replayEdamame =>
      const AssetGenImage('assets/images/replay_edamame.png');

  /// File path: assets/images/seven_da.png
  AssetGenImage get sevenDa =>
      const AssetGenImage('assets/images/seven_da.png');

  /// File path: assets/images/seven_nn.png
  AssetGenImage get sevenNn =>
      const AssetGenImage('assets/images/seven_nn.png');

  /// File path: assets/images/seven_zu.png
  AssetGenImage get sevenZu =>
      const AssetGenImage('assets/images/seven_zu.png');

  /// File path: assets/images/watermelon_zundamochi.png
  AssetGenImage get watermelonZundamochi =>
      const AssetGenImage('assets/images/watermelon_zundamochi.png');

  /// File path: assets/images/zunda.png
  AssetGenImage get zunda => const AssetGenImage('assets/images/zunda.png');

  $AssetsImagesZundamonGen get zundamon => const $AssetsImagesZundamonGen();

  /// List of all assets
  List<AssetGenImage> get values => [
        barVoicevox,
        bellAhiru,
        cherryEdamame,
        mon,
        nanoda,
        replayEdamame,
        sevenDa,
        sevenNn,
        sevenZu,
        watermelonZundamochi,
        zunda
      ];
}

class $AssetsImagesZundamonGen {
  const $AssetsImagesZundamonGen();

  /// File path: assets/images/zundamon/zundamon0001.png
  AssetGenImage get zundamon0001 =>
      const AssetGenImage('assets/images/zundamon/zundamon0001.png');

  /// File path: assets/images/zundamon/zundamon0002.png
  AssetGenImage get zundamon0002 =>
      const AssetGenImage('assets/images/zundamon/zundamon0002.png');

  /// File path: assets/images/zundamon/zundamon0003.png
  AssetGenImage get zundamon0003 =>
      const AssetGenImage('assets/images/zundamon/zundamon0003.png');

  /// File path: assets/images/zundamon/zundamon0004.png
  AssetGenImage get zundamon0004 =>
      const AssetGenImage('assets/images/zundamon/zundamon0004.png');

  /// File path: assets/images/zundamon/zundamon0005.png
  AssetGenImage get zundamon0005 =>
      const AssetGenImage('assets/images/zundamon/zundamon0005.png');

  /// File path: assets/images/zundamon/zundamon0006.png
  AssetGenImage get zundamon0006 =>
      const AssetGenImage('assets/images/zundamon/zundamon0006.png');

  /// List of all assets
  List<AssetGenImage> get values => [
        zundamon0001,
        zundamon0002,
        zundamon0003,
        zundamon0004,
        zundamon0005,
        zundamon0006
      ];
}

class Assets {
  Assets._();

  static const $AssetsAudioGen audio = $AssetsAudioGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName);

  final String _assetName;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
