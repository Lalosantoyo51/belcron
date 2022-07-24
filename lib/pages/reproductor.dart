import 'dart:typed_data';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:diacritic/diacritic.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../components/btn.dart';
import '../components/tab_wrapper.dart';
import '../player_widget.dart';
import '../tabs/global.dart';

typedef OnError = void Function(Exception exception);

const kUrl1 = 'https://luan.xyz/files/audio/ambient_c_motion.mp3';
const kUrl2 = 'https://luan.xyz/files/audio/nasa_on_a_mission.mp3';
const kUrl3 = 'http://bbcmedia.ic.llnwd.net/stream/bbcmedia_radio1xtra_mf_p';

class ReproductorPague extends StatefulWidget {
  const ReproductorPague({Key? key}) : super(key: key);

  @override
  _ReproductorPagueState createState() => _ReproductorPagueState();
}

class _ReproductorPagueState extends State<ReproductorPague> {
  AudioPlayer _player = AudioPlayer(mode: PlayerMode.LOW_LATENCY);
  final String path = '';
  String song = '';
  String nombre = '';
  List list = [];
  Uint8List? img ;
  Future<String> _getPathToDownload() async {
    return ExtStorage.getExternalStoragePublicDirectory(
        ExtStorage.DIRECTORY_DOWNLOADS);
  }

  asignarPath() async {
    final String path = await _getPathToDownload();
  }


  playLocal() async {
    final String path = await _getPathToDownload();

    print('${path + '/music/a.mp3'}');
    var result = await _player.play(path + '/a.mp3', isLocal: true);
    final metadata = await MetadataRetriever.fromFile(File(path + '/a.mp3'));
    print('la meta data ${metadata.albumArt}');
    setState(() {
      img = metadata.albumArt;
      nombre= metadata.trackName!;

    });
  }

  stopMusic() async {
    int result = await _player.stop();
    print('el resultado ${result}');
  }

  resume() async {
    int result = await _player.resume();
  }

  obtenerArchivos() async {
    // TODO: implement initState
    print('aaa');
    final String path = await _getPathToDownload();
    late List file = [];
    file =
        io.Directory(path+'/music').listSync(); //use your folder name insted of resume.
    file.forEach((element) {
      print('obtener canciones');
      if (element.toString().contains('.mp3')) {
        print('aaaa ${removeDiacritics('${element}')}');
        list.add(removeDiacritics(element
                .toString()
                .replaceAll("File: '/storage/emulated/0/Download/music/", '')
                .replaceAll('.mp3', '')
                .replaceAll("'", ''))
            .toString());
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    obtenerArchivos();
    super.initState();

    _player = AudioPlayer();
    cache = AudioCache(fixedPlayer: _player);

    _player.onDurationChanged.listen((d) =>setState(() {musicLength = d;}));

    _player.onAudioPositionChanged.listen((p) =>setState(() {
      print('aaaaa $p');

          position = p;}));

    super.initState();
  }
  //we will need some variables
  bool playing = false; // at the begining we are not playing any song
  IconData playBtn = Icons.play_arrow; // the main state of the play button icon

  //Now let's start by creating our music player
  //first let's declare some object
  late AudioCache cache;

  Duration position = new Duration();
  Duration musicLength = new Duration();

  //we will create a custom slider

  Widget slider() {
    return Container(
      width: 300.0,
      child: Slider.adaptive(
          activeColor: Colors.black87,
          inactiveColor: Colors.black45,
          value: position.inSeconds.toDouble(),
          max: musicLength.inSeconds.toDouble(),
          onChanged: (value) {
            seekToSec(value.toInt());
          }),
    );
  }

  //let's create the seek function that will allow us to go to a certain position of the music
  void seekToSec(int sec) {
    Duration newPos = Duration(seconds: sec);
    _player.seek(newPos);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //let's start by creating the main UI of the app
      body: Container(
        width:MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: Colors.black
        ),
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
                  padding:  EdgeInsets.only(left: 50.0),
                  child: Text(
                    "$nombre",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 38.0,
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
                    child: img != null ? Image.memory(img!):Container(),
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white12,
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
                        Container(
                          width: 500.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "${position.inMinutes}:${position.inSeconds.remainder(60)}",
                                style: TextStyle(
                                  fontSize: 18.0,
                                ),
                              ),
                              slider(),
                              Text(
                                "${musicLength.inMinutes}:${musicLength.inSeconds.remainder(60)}",
                                style: TextStyle(
                                  fontSize: 18.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              iconSize: 45.0,
                              color: Colors.black45,
                              onPressed: () {},
                              icon: Icon(
                                Icons.skip_previous,
                              ),
                            ),
                            IconButton(
                              iconSize: 62.0,
                              color: Colors.black87,
                              onPressed: () {
                                print('hola');
                                //here we will add the functionality of the play button
                                if (!playing) {
                                  //now let's play the song
                                  playLocal();
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
                              onPressed: () {},
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
          ),
        ),
      ),
    );
  }
}