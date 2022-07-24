import 'dart:io';

import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:just_audio/just_audio.dart';
import 'package:scanner/models/song_model.dart';
import 'dart:io' as io;
import 'package:rxdart/rxdart.dart';
import 'package:audio_session/audio_session.dart';
import 'package:scanner/widgets/seekbar.dart';


class ProviderReproductor with ChangeNotifier, DiagnosticableTreeMixin {
  bool playing = true; // at the begining we are not playing any song
  List<SongModel> _list = [];
  late SongModel _song = SongModel();
  bool _isMostrar = false;
  // AudioPlayer _player = AudioPlayer();

  List<SongModel> get list => _list;


  // AudioPlayer get player => _player;

  set song(SongModel value) {
    _song = value;
  }

  SongModel get song => _song;

  // set player(AudioPlayer value) {
  //   _player = value;
  // }

  bool get isMostrar => _isMostrar;

  set isMostrar(bool value) {
    _isMostrar = value;
  }

  Future<String> getPathToDownload() async {
    return ExtStorage.getExternalStoragePublicDirectory(
        ExtStorage.DIRECTORY_DOWNLOADS);
  }

  obtenerCanciones() async {
    int contrador = 0;
    final String path = await getPathToDownload();
    late List file = [];
    file = io.Directory(path + '/music')
        .listSync(); //use your folder name insted of resume.
    if(file.length != list.length){
      _list = [];
      file.forEach((element) async {
        if (element.toString().contains('.mp3')) {
          contrador++;
          var nombre = element
              .toString()
              .replaceAll(path + '/music/', '')
              .replaceAll('File:', '')
              .replaceAll("'", '')
              .replaceAll(' ', '');
          final metadata = await MetadataRetriever.fromFile(
              File(path + '/music/' + '$nombre'));
          var cancion = _list.where((element) => element.nombre == nombre);
          if (cancion.isEmpty) {
            _list.add(SongModel(
              path: path + '/music' + '/${nombre}',
                nombre: nombre,
                trackName: metadata.trackName,
                albumName: metadata.albumName,
                albumArtistName: metadata.albumArtistName,
                trackNumber: metadata.trackNumber,
                albumLength: metadata.albumLength,
                year: metadata.year,
                genre: metadata.genre,
                authorName: metadata.authorName,
                writerName: metadata.writerName,
                discNumber: metadata.discNumber,
                mimeType: metadata.mimeType,
                trackDuration: metadata.trackDuration,
                bitrate: metadata.bitrate,
                albumArt: metadata.albumArt));
          }

          _list.sort((a, b) => a.trackName!.compareTo(b.trackName!));
        }
      });
      print('cantidad del list ${_list.length}');
    }else{

    }


  }

/*  init(AudioPlayer _player) async {
    final String path = await getPathToDownload();

    await obtenerCanciones();
    // Inform the operating system of our app's audio attributes etc.
    // We pick a reasonable default for an app that plays speech.

    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    // Listen to errors during playback.
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
          print('A stream error occurred: $e');
        });

    notifyListeners();
  }*/
  // playLocal(SongModel song,AudioPlayer _player) async {
  //   final String path = await getPathToDownload();
  //   _player.stop();
  //   var result = await _player.setFilePath(path + '/music' + '/${_song.nombre}');
  //   _player.play();
  //   //AudioPlayerHandler(_player, list,path: song.trackName).addInfo();
  //   //_audioHandler.playbackState.value.playing;
  //   // final _item = MediaItem(
  //   //   id: 'aaaaaaaaaaaa2',
  //   //   title: "22",
  //   //   artist: "Science Friday and WNYC Studios",
  //   //   duration: const Duration(milliseconds: 5739820),
  //   // );
  //   // final metadata =
  //   //     await MetadataRetriever.fromFile(File(path + '/${song.nombre}'));
  //   // print('la meta data ${metadata.albumArt}');
  //   notifyListeners();
  // }
  mostrar(){
    print('$isMostrar');
    if(!_isMostrar){
      _isMostrar=!_isMostrar;
    }else{
      _isMostrar=!_isMostrar;

    }
    notifyListeners();
  }
  refrescar(){
    notifyListeners();

  }




  hola(AudioPlayer _player){

    //metodo para escuchar un stream
    Stream<Duration> stream = _player.positionStream;
    stream.listen((data) {
      print("DataReceived: "+'${data}');
    }, onDone: () {
      print("Task Done");
    }, onError: (error) {
      print("Some Error");
    });
  }


  Future<String> getData() async {
    await Future.delayed(Duration(seconds: 5)); // Retraso simulado
    print("Fetched Data");
    return "This a test data";
  }
  void seekToSec(int sec,AudioPlayer _player) {
    Duration newPos = Duration(seconds: sec);
    _player.seek(newPos);
    notifyListeners();
  }


}