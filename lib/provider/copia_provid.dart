// import 'dart:io';
//
// import 'package:audioplayers/audioplayers.dart';
// import 'package:ext_storage/ext_storage.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_media_metadata/flutter_media_metadata.dart';
// import 'package:scanner/models/song_model.dart';
//
// class ProviderReproductor with ChangeNotifier, DiagnosticableTreeMixin {
//   late SongModel song = SongModel();
//   AudioPlayer _player = AudioPlayer(mode: PlayerMode.LOW_LATENCY);
//
//   Duration get position => _position;
//
//   set position(Duration value) {
//     _position = value;
//   }
//
//   Duration _position = new Duration();
//   Duration _musicLength = new Duration();
//   late AudioCache cache;
//   bool playing = false; // at the begining we are not playing any song
//
//
//   Future<String> getPathToDownload() async {
//     return ExtStorage.getExternalStoragePublicDirectory(
//         ExtStorage.DIRECTORY_DOWNLOADS);
//   }
//
//   AudioPlayer get player => _player;
//
//   init(){
//     _player = AudioPlayer();
//     cache = AudioCache(fixedPlayer:_player);
//
//     _player.onDurationChanged.listen((d){
//       _musicLength = d;
//       notifyListeners();
//     });
//     _player.onAudioPositionChanged.listen((p) => () {
//       print('aaaa${p}');
//       _position = p;
//       notifyListeners();
//
//     });
//
//
//   }
//
//
//
//
//   playLocal(SongModel song) async {
//     final String path = await getPathToDownload();
//     playing = false;
//     _player.stop();
//     print('${_musicLength}');
//     var result =
//     await _player.play(path + '/music' + '/${song.nombre}', isLocal: true);
//     final metadata =
//     await MetadataRetriever.fromFile(File(path + '/${song.nombre}'));
//     print('la meta data ${metadata.albumArt}');
//     notifyListeners();
//   }
//
//   stopMusic() async {
//     int result = await _player.stop();
//     print('el resultado ${result}');
//   }
//
//   resume() async {
//     int result = await _player.resume();
//   }
//   nextSong(index,list){
//     print('index ${index}');
//     print('index ${list.length}');
//     if(list.length == index){
//       print('se acabo la lista');
//       index = 0;
//       playLocal(list[index]);
//       song = list[index];
//       playing = true;
//
//     }else{
//
//       index++;
//       print('el indez ${index}');
//       playLocal(list[index]);
//       song = list[index];
//       playing = true;
//       notifyListeners();
//
//     }
//   }
//
//   Duration get musicLength => _musicLength;
//
//   set musicLength(Duration value) {
//     _musicLength = value;
//   }
// }