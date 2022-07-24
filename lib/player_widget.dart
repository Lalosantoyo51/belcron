import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/notifications.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';

class PlayerWidget extends StatefulWidget {
   String nameSong = '';
   AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);
   PlayerWidget({
    Key? key,
     required this.audioPlayer,
    required this.nameSong}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState(nameSong,audioPlayer);
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);
  String path = '';
  String nameSong = '';
  PlayerState? _audioPlayerState;
  Duration? _duration;
  Duration? _position;

  PlayerState _playerState = PlayerState.STOPPED;
  PlayingRoute _playingRouteState = PlayingRoute.SPEAKERS;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerErrorSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription<PlayerControlCommand>? _playerControlCommandSubscription;

  bool get _isPlaying => _playerState == PlayerState.PLAYING;
  bool get _isPaused => _playerState == PlayerState.PAUSED;
  String get _durationText => _duration?.toString().split('.').first ?? '';
  String get _positionText => _position?.toString().split('.').first ?? '';

  bool get _isPlayingThroughEarpiece =>
      _playingRouteState == PlayingRoute.EARPIECE;

  _PlayerWidgetState(this.nameSong,this.audioPlayer);
  Future<String> _getPathToDownload() async {
    return ExtStorage.getExternalStoragePublicDirectory(
        ExtStorage.DIRECTORY_DOWNLOADS);
  }
  asignarPath()async{
    path = await _getPathToDownload();
    setState(() {});
  }
  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  @override
  void dispose() {
   audioPlayer.dispose();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _playerControlCommandSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: const Key('play_button'),
              onPressed: _isPlaying ? null : _play,
              iconSize: 64.0,
              icon: const Icon(Icons.play_arrow),
              color: Colors.cyan,
            ),
            IconButton(
              key: const Key('pause_button'),
              onPressed: _isPlaying ? _pause : null,
              iconSize: 64.0,
              icon: const Icon(Icons.pause),
              color: Colors.cyan,
            ),
            IconButton(
              key: const Key('stop_button'),
              onPressed: _isPlaying || _isPaused ? _stop : null,
              iconSize: 64.0,
              icon: const Icon(Icons.stop),
              color: Colors.cyan,
            ),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Stack(
                children: [
                  Slider(
                    onChanged: (v) {
                      final duration = _duration;
                      if (duration == null) {
                        return;
                      }
                      print('la duracion ${duration}');
                      final Position = v * duration.inMilliseconds;
                      audioPlayer
                          .seek(Duration(milliseconds: Position.round()));
                    },
                    value: (_position != null &&
                        _duration != null &&
                        _position!.inMilliseconds > 0 &&
                        _position!.inMilliseconds <
                            _duration!.inMilliseconds)
                        ? _position!.inMilliseconds / _duration!.inMilliseconds
                        : 0.0,
                  ),
                ],
              ),
            ),
            Text(
              _position != null
                  ? '$_positionText / $_durationText'
                  : _duration != null
                  ? _durationText
                  : '',
              style: const TextStyle(fontSize: 24.0),
            ),
          ],
        ),
        Text('State: $_audioPlayerState'),
      ],
    );
  }

  void _initAudioPlayer() {
    audioPlayer = AudioPlayer();

    _durationSubscription = audioPlayer.onDurationChanged.listen((duration) {
      print('la duracion ${duration}');
      setState(() => _duration = duration);

      if (Theme.of(context).platform == TargetPlatform.iOS) {
        // optional: listen for notification updates in the background
        audioPlayer.notificationService.startHeadlessService();

        // set at least title to see the notification bar on ios.
        audioPlayer.notificationService.setNotification(
          title: 'App Name',
          artist: 'Artist or blank',
          albumTitle: 'Name or blank',
          imageUrl: 'Image URL or blank',
          forwardSkipInterval: const Duration(seconds: 30), // default is 30s
          backwardSkipInterval: const Duration(seconds: 30), // default is 30s
          duration: duration,
          enableNextTrackButton: true,
          enablePreviousTrackButton: true,
        );
      }
    });

    _positionSubscription = audioPlayer.onAudioPositionChanged.listen(
          (p) => setState(() => _position = p),
    );

    _playerCompleteSubscription =
        audioPlayer.onPlayerCompletion.listen((event) {
          _onComplete();
          setState(() {
            _position = _duration;
          });
        });

    _playerErrorSubscription =audioPlayer.onPlayerError.listen((msg) {
      print('audioPlayer error : $msg');
      setState(() {
        _playerState = PlayerState.STOPPED;
        _duration = const Duration();
        _position = const Duration();
      });
    });

    _playerControlCommandSubscription =
       audioPlayer.notificationService.onPlayerCommand.listen((command) {
          print('command: $command');
        });

    audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _audioPlayerState = state;
        });
      }
    });

    audioPlayer.onNotificationPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _audioPlayerState = state);
      }
    });

    _playingRouteState = PlayingRoute.SPEAKERS;
  }

  Future<int> _play() async {
    print('hola ${widget.nameSong}');
    final String path = await _getPathToDownload();

    final playPosition = (_position != null &&
        _duration != null &&
        _position!.inMilliseconds > 0 &&
        _position!.inMilliseconds < _duration!.inMilliseconds)
        ? _position
        : null;
    final result = await audioPlayer.play(path+'/music/${widget.nameSong}.mp3',isLocal: true, position: playPosition);
    if (result == 1) {
      setState(() => _playerState = PlayerState.PLAYING);
    }

    return result;
  }

  Future<int> _pause() async {
    final result = await audioPlayer.pause();
    if (result == 1) {
      setState(() => _playerState = PlayerState.PAUSED);
    }
    return result;
  }

  Future<int> _earpieceOrSpeakersToggle() async {
    final result = await audioPlayer.earpieceOrSpeakersToggle();
    if (result == 1) {
      setState(() => _playingRouteState = _playingRouteState.toggle());
    }
    return result;
  }

  Future<int> _stop() async {
    final result = await audioPlayer.stop();
    if (result == 1) {
      setState(() {
        _playerState = PlayerState.STOPPED;
        _position = const Duration();
      });
    }
    return result;
  }

  void _onComplete() {
    setState(() => _playerState = PlayerState.STOPPED);
  }
}