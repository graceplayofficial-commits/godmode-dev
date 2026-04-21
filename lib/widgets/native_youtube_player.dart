import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeYoutubePlayer extends StatefulWidget {
  final String videoId;
  final bool autoPlay;
  final VoidCallback? onReady;
  final ValueChanged<String>? onError;

  const NativeYoutubePlayer({
    super.key,
    required this.videoId,
    this.autoPlay = false,
    this.onReady,
    this.onError,
  });

  @override
  State<NativeYoutubePlayer> createState() => NativeYoutubePlayerState();
}

class NativeYoutubePlayerState extends State<NativeYoutubePlayer> {
  MethodChannel? _channel;

  void play() => _channel?.invokeMethod('play');
  void pause() => _channel?.invokeMethod('pause');
  void loadVideo(String videoId) => _channel?.invokeMethod('loadVideo', {'videoId': videoId});

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('youtube-player-$id');
    _channel!.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onReady':
          widget.onReady?.call();
        case 'onError':
          widget.onError?.call(call.arguments?.toString() ?? 'unknown');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final params = <String, dynamic>{
      'videoId': widget.videoId,
      'autoPlay': widget.autoPlay,
    };

    if (!kIsWeb && Platform.isAndroid) {
      return AndroidView(
        viewType: 'youtube-player',
        creationParams: params,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else if (!kIsWeb && Platform.isIOS) {
      return UiKitView(
        viewType: 'youtube-player',
        creationParams: params,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }

    // 데스크톱/웹 fallback
    return Container(
      color: Colors.black,
      child: const Center(child: Text('YouTube 플레이어는 모바일에서만 지원됩니다', style: TextStyle(color: Colors.white54))),
    );
  }
}
