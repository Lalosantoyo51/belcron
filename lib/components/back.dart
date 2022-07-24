import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:scanner/models/song_model.dart';

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {




  AudioPlayer _player = AudioPlayer();
  List<SongModel> _list = [];
  String _path ='';
  String _a = '';
  /// Initialise our audio handler.
  AudioPlayerHandler(AudioPlayer audioPlayer, List<SongModel> list,
      {String? path,String? a}) {
    print('aaaaaaaaa $a');
    var _item = MediaItem(
      id: '1',
      title: "$a",
      artist: "Science Friday and WNYC Studios",
      duration: const Duration(milliseconds: 5739820),
    );

    mediaItem.add(_item);



    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    // _player.setFilePath(path!);


    // print('path ${path} ${list.length}');
    // So that our clients (the Flutter UI and the system notification) know
    // what state to display, here we set up our audio handler to broadcast all
    // playback state changes as they happen via playbackState...
    // ... and also the current media item via mediaItem.
    // _list.indexOf(_)
    // var buscar = _list.where((element) => element.nombre == _path);



    // Load the player.
  }


   onCustomAction(path) {
     var _item = MediaItem(
       id: '1',
       title: "aaaa",
       artist: "Science Friday and WNYC Studios",
       duration: const Duration(milliseconds: 5739820),
     );
     _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
     mediaItem.add(_item);
     // _player.setFilePath(path!);


     // print('path ${path} ${list.length}');
     // So that our clients (the Flutter UI and the system notification) know
     // what state to display, here we set up our audio handler to broadcast all
     // playback state changes as they happen via playbackState...
     _player.playbackEventStream.map(_transformEvent).pipe(playbackState);

  }


  addInfo(){

    final _item = MediaItem(
      id: 'aaaaaaaaaaaa2',
      title: "${_path}22",
      artist: "Science Friday and WNYC Studios",
      duration: const Duration(milliseconds: 5739820),
    );
    // mediaItem.
    mediaItem.add(_item);
    mediaItem.last;
    _player.play();
  }
  // In this simple example, we handle only 4 actions: play, pause, seek and
  // stop. Any button press from the Flutter UI, notification, lock screen or
  // headset will be routed through to these 4 methods so that you can handle
  // your audio playback logic in one place.

  @override
  Future<void> play() async {
    final _item = MediaItem(
      id: 'aaaaaaaaaaaa2',
      title: "${_path}pinche perro",
      artist: "Science Friday and WNYC Studios",
      duration: const Duration(milliseconds: 5739820),
    );
    // mediaItem.
    mediaItem.add(_item);
    print('aaaaaaaaaaaaaaaaaaaaaaaaa perro${_a}');
    return _player.play();


}
  @override
  Future<void> pause() {
    print('hola ');
    return _player.pause();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  /// Transform a just_audio event into an audio_service state.
  ///
  /// This method is used from the constructor. Every event received from the
  /// just_audio player will be transformed into an audio_service state so that
  /// it can be broadcast to audio_service clients.
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}