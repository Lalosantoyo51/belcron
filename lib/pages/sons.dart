import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:scanner/models/song_model.dart';
import 'package:scanner/provider/provider_derectorio.dart';
import 'dart:io' as io;
import 'dart:io';
import 'package:marquee/marquee.dart';
import 'package:scanner/provider/provider_reproductor.dart';
import 'package:scanner/widgets/seekbar.dart';
import 'package:rxdart/rxdart.dart';

late AudioHandler _audioHandler;
AudioPlayer _player = AudioPlayer();

//AudioPlayer _player = AudioPlayer(mode: PlayerMode.LOW_LATENCY);
bool playing = true; // at the begining we are not playing any song
late ProviderDirectorio directorio;
late ProviderReproductor reproductor;
IconData playBtn = Icons.play_arrow;
List<SongModel> list = [];
late SongModel song = SongModel();
int index = 0;

//new

//new

class SonsView extends StatefulWidget {
  SonsView({Key? key}) : super(key: key);

  @override
  State<SonsView> createState() => _SonsViewState();
}

class _SonsViewState extends State<SonsView> {
  late ProviderReproductor reproductor;

  @override
  void initState() {
    // TODO: implement initState
    directorio = Provider.of<ProviderDirectorio>(context, listen: false);
    reproductor = Provider.of<ProviderReproductor>(context, listen: false);
    // reproductor.init();
    // obtenerCanciones();
    init();
    if(song != null){
      print('duracion ${_player.duration}');
      Stream<Duration> stream = _player.positionStream;
      stream.listen((data) {
        if(data == _player.duration){
          var index =
          reproductor.list.indexOf(song);
          print('hola ${song.path} ${reproductor.list.length} , ${index}');

          if(reproductor.list.length != index+1 ){
            SongModel newSong =
            reproductor.list[index + 1];
            song = newSong;
            reproductor.song = newSong;
            reproductor.refrescar();
            playLocal(newSong);
            print('${reproductor.song.nombre}');
          }else{
            SongModel newSong =
            reproductor.list[0];
            song = newSong;
            reproductor.song = newSong;
            reproductor.refrescar();
            playLocal(newSong);          }

        }
      }, onDone: () {
        print("Task Done");
      }, onError: (error) {
        print("Some Error");
      });
    }
    super.initState();
  }

  init() async {
    _audioHandler = await AudioService.init(
      builder: () => AudioPlayerHandler(_player, reproductor.list, context),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
        androidNotificationChannelName: 'Audio playback',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
        androidNotificationClickStartsActivity: true,
        androidResumeOnClick: true,
        androidShowNotificationBadge: true
      ),
    );
  }

  playLocal(
    SongModel song,
  ) async {
    final String path = await reproductor.getPathToDownload();
    _player.stop();
    var result = await _player.setFilePath(path + '/music' + '/${song.nombre}');
    _player.play();
    var index =
    reproductor.list.indexOf(song);
    print('hola ${song.path} ${reproductor.list.length} , ${index+1}');


    //AudioPlayerHandler(_player, list,path: song.trackName).addInfo();
    //_audioHandler.playbackState.value.playing;
    // final _item = MediaItem(
    //   id: 'aaaaaaaaaaaa2',
    //   title: "22",
    //   artist: "Science Friday and WNYC Studios",
    //   duration: const Duration(milliseconds: 5739820),
    // );
    // final metadata =
    //     await MetadataRetriever.fromFile(File(path + '/${song.nombre}'));
    // print('la meta data ${metadata.albumArt}');
  }

  // nextSong(index,list){
  //   print('index ${index}');
  //   print('index ${list.length}');
  //   if(list.length == index){
  //     print('se acabo la lista');
  //     index = 0;
  //     playLocal(list[index]);
  //     song = list[index];
  //     playing = true;
  //
  //   }else{
  //
  //     index++;
  //     print('el indez ${index}');
  //     playLocal(list[index]);
  //     song = list[index];
  //     playing = true;
  //
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final reproductor = Provider.of<ProviderReproductor>(context);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          title: Text('Canciones ${reproductor.list.length}'),
          centerTitle: true,
          backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.black,
        body: Container(
          width: width,
          height: height,
          child: Stack(
            children: [
              Container(
                width: width,
                height: height / 1.35,
                padding: EdgeInsets.all(20),
                child: reproductor.list.isNotEmpty
                    ? ListView.builder(
                        itemCount: reproductor.list.length,
                        itemBuilder: (context, index2) {
                          return TextButton(
                            onPressed: () async {
                              // stopMusic();

                               index = index2;
                              print('posicion${index2}');
                              directorio.mostrar = true;
                              song = reproductor.list[index2];
                              reproductor.song = reproductor.list[index2];
                              playLocal(song);
                              playing = true;
                              playBtn = Icons.pause;
                              // _audioHandler =(await AudioService.stop) as AudioHandler;
                              var stream_b = MediaItem(
                                id: 'some URL', //
                                title: 'Stream B',
                              );

                              _audioHandler.play();
                              setState(() {});
                            },
                            child: Column(children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Image.memory(
                                    reproductor.list[index2].albumArt!,
                                    fit: BoxFit.fitWidth,
                                    height: 40,
                                    width: 50,
                                  ),
                                  Container(
                                      width: width / 1.5,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${reproductor.list[index2].trackName}',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            softWrap: true,
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ],
                                      )),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              )
                            ]),
                          );
                        })
                    : Center(
                        child: Text('no hay archivos aun'),
                      ),
              ),
              directorio.mostrar == true
                  ? Positioned(
                      bottom: 0,
                      child: TextButton(
                        onPressed: () {
                          reproductor.mostrar();
                        },
                        child: Container(
                          color: Colors.white30,
                          width: width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Image.memory(
                                reproductor.song.albumArt!,
                                fit: BoxFit.fitWidth,
                                height: 100,
                                width: 100,
                              ),
                              Container(
                                  width: width / 2.5,
                                  height: 40,
                                  child: Center(
                                    child: Marquee(
                                      text: reproductor.song.trackName!,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        iconSize: 35.0,
                                        color: Colors.white,
                                        onPressed: () {
                                          print('aaa');
                                          //here we will add the functionality of the play button
                                          if (playing == false) {
                                            //now let's play the song
                                            _player.play();
                                            print('hola');
                                            setState(() {
                                              playBtn = Icons.pause;
                                              playing = true;
                                            });
                                          } else {
                                            _player.pause();
                                            setState(() {
                                              playBtn = Icons.play_arrow;
                                              playing = false;
                                            });
                                          }
                                        },
                                        icon: Icon(
                                          playBtn,
                                        ),
                                      ),
                                      IconButton(
                                        iconSize: 30.0,
                                        color: Colors.white30,
                                        onPressed: () {
                                          print('hola ${song.path} }');
                                          var index =
                                              reproductor.list.indexOf(song);
                                          SongModel newSong =
                                              reproductor.list[index + 1];
                                          song = newSong;
                                          reproductor.song = newSong;
                                          reproductor.refrescar();
                                          playLocal(newSong);
                                          print('${reproductor.song.nombre}');
                                        },
                                        icon: Icon(
                                          Icons.skip_next,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ))
                  : Container()
            ],
          ),
        ));
  }
}

class ReproductorView extends StatefulWidget {
  ReproductorView({
    Key? key,
  }) : super(key: key);

  @override
  State<ReproductorView> createState() => _ReproductorViewState();
}

class _ReproductorViewState extends State<ReproductorView> {
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _player.positionStream,
          _player.bufferedPositionStream,
          _player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));
  @override
  Widget build(BuildContext context) {
    final reproductor = Provider.of<ProviderReproductor>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Canciones'),
        backgroundColor: Colors.black,
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              setState(() {
                reproductor.mostrar();
              });
            },
            icon: Icon(Icons.arrow_back_outlined)),
      ),
      //let's start by creating the main UI of the app
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: Colors.black),
        child: Padding(
            padding: EdgeInsets.only(
              top: 48.0,
            ),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Let's add some text title
                  Padding(
                    padding: EdgeInsets.only(left: 50.0),
                    child: Text(
                      "${reproductor.song.trackName}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 24.0,
                  ),
                  //Let's add the music cover
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 280.0,
                      child: reproductor.song.albumArt != null
                          ? Image.memory(reproductor.song.albumArt!)
                          : Container(),
                    ),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.0),
                          topRight: Radius.circular(30.0),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          //Let's start by adding the controller
                          //let's add the time indicator text
                          StreamBuilder<PositionData>(
                              stream: _positionDataStream,
                              builder: (context, snapshot) {
                                final positionData = snapshot.data;
                                return Container(
                                  width: 500.0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${positionData!.position.inMinutes}:${positionData.position.inSeconds.remainder(60)}",
                                        style: TextStyle(
                                          fontSize: 18.0,
                                        ),
                                      ),
                                      Container(
                                        width: 300.0,
                                        child: Slider.adaptive(
                                            activeColor: Colors.black87,
                                            inactiveColor: Colors.black45,
                                            value: positionData
                                                .position.inSeconds
                                                .toDouble(),
                                            max: positionData.duration.inSeconds
                                                .toDouble(),
                                            onChanged: (value) {
                                              reproductor.seekToSec(
                                                  value.toInt(), _player);
                                            }),
                                      ),
                                      Text(
                                        "${positionData.duration.inMinutes}:${positionData.duration.inSeconds.remainder(60)}",
                                        style: TextStyle(
                                          fontSize: 18.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                iconSize: 45.0,
                                color: Colors.black45,
                                onPressed: () {
                                  print('hola ${song.path} }');
                                  var index = reproductor.list.indexOf(song);
                                  SongModel newSong =
                                      reproductor.list[index - 1];
                                  song = newSong;
                                  reproductor.song = newSong;
                                  reproductor.refrescar();
                                  _player.setFilePath(newSong.path!);
                                  print('${reproductor.song.nombre}');
                                },
                                icon: Icon(
                                  Icons.skip_previous,
                                ),
                              ),
                              IconButton(
                                iconSize: 62.0,
                                color: Colors.black87,
                                onPressed: () {
                                  print('hola 2');
                                  //here we will add the functionality of the play button
                                   if (!playing) {
                                     //now let's play the song
                                     _player.play();
                                     setState(() {
                                       playBtn = Icons.pause;
                                       playing = true;
                                     });
                                   } else {
                                     _player.pause();
                                     setState(() {
                                       playBtn = Icons.play_arrow;
                                       playing = false;
                                     });
                                   }
                                },
                                icon: Icon(
                                  playBtn,
                                ),
                              ),
                              IconButton(
                                iconSize: 45.0,
                                color: Colors.black45,
                                onPressed: () {
                                  print('hola ${song.path} }');
                                  var index = reproductor.list.indexOf(song);
                                  SongModel newSong =
                                      reproductor.list[index + 1];
                                  song = newSong;
                                  reproductor.song = newSong;
                                  reproductor.refrescar();
                                  _player.setFilePath(newSong.path!);
                                  print('${reproductor.song.nombre}');
                                },
                                icon: Icon(
                                  Icons.skip_next,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  List<SongModel> _list = [];
  String _path = '';
  String _a = '';

  /// Initialise our audio handler.
  AudioPlayerHandler(
      AudioPlayer audioPlayer, List<SongModel> list, BuildContext contex,
      {String? path, String? a}) {
    reproductor = Provider.of<ProviderReproductor>(contex, listen: false);

    print('aaaaaaaaa $a');
    var _item = MediaItem(
      id: '1',
      title: "$a",
      artist: "Science Friday and WNYC Studios",
      duration: const Duration(milliseconds: 5739820),
    );

    mediaItem.add(_item);
    _list = list;

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
  playLocal(
    SongModel song,
  ) async {
    _player.play();
    //AudioPlayerHandler(_player, list,path: song.trackName).addInfo();
    //_audioHandler.playbackState.value.playing;
    // final _item = MediaItem(
    //   id: 'aaaaaaaaaaaa2',
    //   title: "22",
    //   artist: "Science Friday and WNYC Studios",
    //   duration: const Duration(milliseconds: 5739820),
    // );
    // final metadata =
    //     await MetadataRetriever.fromFile(File(path + '/${song.nombre}'));
    // print('la meta data ${metadata.albumArt}');
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

  addInfo() {
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
    print('hola entra al play');
    final _item = MediaItem(
      id: 'aaaaaaaaaaaa2',
      title: "${song.trackName}",
      artist: "${song.nombre}",
    );
    // mediaItem.
    mediaItem.add(_item);
    print('aaaaaaaaaaaaaaaaaaaaaaaaa perro${song.nombre}');
    return _player.play();
  }

  @override
  Future<void> pause() {
    return _player.pause();
  }

  @override
  Future<void> skipToNext() async {
    print('hola ${song.path} }');
    var index = _list.indexOf(song);
    SongModel newSong = _list[index + 1];
    song = newSong;
    reproductor.song = newSong;
    reproductor.refrescar();
    print('${reproductor.song.nombre}');
    var result = await _player.setFilePath(newSong.path!);
    final _item = MediaItem(
      id: 'aaaaaaaaaaaa2',
      title: "${song.trackName}",
      artist: "${song.nombre}",
      duration: const Duration(milliseconds: 5739820),
    );
    // mediaItem.
    mediaItem.add(_item);
    return _player.play();
  }

  @override
  Future<void> skipToPrevious() async {
    print('hola ${song.path} }');
    var index = _list.indexOf(song);
    SongModel newSong = _list[index - 1];
    song = newSong;
    reproductor.song = newSong;
    reproductor.refrescar();
    print('${reproductor.song.nombre}');
    print('${newSong.nombre}');

    var result = await _player.setFilePath(newSong.path!);
    final _item = MediaItem(
      id: 'aaaaaaaaaaaa2',
      title: "${song.trackName}",
      artist: "${song.nombre}",
      duration: const Duration(milliseconds: 5739820),
    );
    // mediaItem.
    mediaItem.add(_item);
    return _player.play();
  }

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
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      captioningEnabled: true,
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
