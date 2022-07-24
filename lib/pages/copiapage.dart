import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:scanner/components/back.dart';
import 'package:scanner/pages/descargas.dart';
import 'package:scanner/pages/webview.dart';
import 'package:scanner/provider/provider_derectorio.dart';
import 'package:scanner/provider/provider_download.dart';
import 'package:scanner/provider/provider_reproductor.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:scanner/models/song_model.dart';
import 'dart:io' as io;
import 'dart:io';
import 'package:marquee/marquee.dart';
import 'package:audio_session/audio_session.dart';
import 'package:scanner/widgets/seekbar.dart';
import 'package:rxdart/rxdart.dart';

late AudioHandler _audioHandler;

//AudioPlayer _player = AudioPlayer(mode: PlayerMode.LOW_LATENCY);
bool playing = true; // at the begining we are not playing any song
late ProviderDirectorio directorio;
late ProviderReproductor reproductor;
IconData playBtn = Icons.play_arrow;
List<SongModel> list = [];
late SongModel song = SongModel();
bool isMostrar = false;

//new
final _player = AudioPlayer();

//new

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  //late AudioCache cache;

  int pageIndex = 0;

  final pages = [];

  late ProviderDirectorio directorio;
  @override
  void initState() {
    directorio = Provider.of<ProviderDirectorio>(context, listen: false);

    // TODO: implement initState
    //new
    //new

    //_player = AudioPlayer();
    //cache = AudioCache(fixedPlayer: _player);
    //_player.onDurationChanged.listen((d) =>setState(() {musicLength = d;}));
    //_player.onAudioPositionChanged.listen((p) =>setState(() {
    //  print('aaaaa $p   $musicLength');
    //  playing = true;
    //  setState(() {
    //  });
    //  position = p;}));

    init();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    super.initState();
  }

  obtenerCanciones() async {
    int contrador = 0;
    print('obtener canciones');
    final String path = await directorio.getPathToDownload();
    late List file = [];
    file = io.Directory(path + '/music').listSync(); //
    int a = 0; // use your folder name insted of resume.
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
        var cancion = list.where((element) => element.nombre == nombre);
        if (cancion.isEmpty) {
          list.add(SongModel(
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

        //list.sort((a, b) => a.trackName!.compareTo(b.trackName!));
        //setState(() {});
      }
      a++;
      if (a == file.length) {
        print('fin del foreach ${list.length}');
        _audioHandler = await AudioService.init(
          builder: () => AudioPlayerHandler(_player, list),
          config: const AudioServiceConfig(
            androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
            androidNotificationChannelName: 'Audio playback',
            androidNotificationOngoing: true,
          ),
        );
      }
    });

    print(' contador $contrador');
  }

  init() async {
    final String path = await directorio.getPathToDownload();

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
  }
  //agregar tripulante
  //checar comentarios

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    // Release decoders and buffers back to the operating system making them
    // available for other apps to use.
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final downlaod = Provider.of<DownloadProvider>(context);
    downlaod.obtenerContador();
    return Scaffold(
      body: [
        WebView(),
        DescargasPage(),
        // const ReproductorPague(),
        isMostrar == false ? SonsView() : a()
      ][pageIndex],
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.black54,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              enableFeedback: false,
              onPressed: () {
                setState(() {
                  pageIndex = 0;
                });
              },
              icon: Icon(
                Icons.home,
                color: pageIndex == 0 ? Colors.blue : Colors.white,
                size: 35,
              ),
            ),
            Stack(
              children: [
                IconButton(
                  enableFeedback: false,
                  onPressed: () {
                    setState(() {
                      pageIndex = 1;
                    });
                  },
                  icon: Icon(
                    Icons.download_for_offline_outlined,
                    color: pageIndex == 1 ? Colors.blue : Colors.white,
                    size: 40,
                  ),
                ),
                downlaod.numDes > 0
                    ? Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: CircleAvatar(
                    child: Text('${downlaod.numDes}',
                        style: TextStyle(color: Colors.white)),
                    radius: 15,
                    backgroundColor: Colors.red,
                  ),
                )
                    : Container()
              ],
            ),
            IconButton(
              enableFeedback: false,
              onPressed: () {
                setState(() {
                  pageIndex = 2;
                });
              },
              icon: Icon(
                Icons.play_circle_fill,
                color: pageIndex == 2 ? Colors.blue : Colors.white,
                size: 35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//vista para cargar la lista  de canciones
class SonsView extends StatefulWidget {
  const SonsView({Key? key}) : super(key: key);

  @override
  State<SonsView> createState() => _SonsViewState();
}

class _SonsViewState extends State<SonsView> {
  late int index;

  @override
  void initState() {
    // TODO: implement initState
    directorio = Provider.of<ProviderDirectorio>(context, listen: false);
    /*   reproductor = Provider.of<ProviderReproductor>(context, listen: true);
    reproductor.init();*/
    obtenerCanciones();
    super.initState();
  }

  obtenerCanciones() async {
    int contrador = 0;
    print('obtener canciones');
    final String path = await directorio.getPathToDownload();
    late List file = [];
    file = io.Directory(path + '/music')
        .listSync(); //use your folder name insted of resume.
    file.forEach((element) async {
      if (element.toString().contains('.mp3')) {
        print('${element}');
        contrador++;
        var nombre = element
            .toString()
            .replaceAll(path + '/music/', '')
            .replaceAll('File:', '')
            .replaceAll("'", '')
            .replaceAll(' ', '');
        print('nombre ${nombre}');
        final metadata = await MetadataRetriever.fromFile(
            File(path + '/music/' + '$nombre'));
        var cancion = list.where((element) => element.nombre == nombre);
        if (cancion.isEmpty) {
          list.add(SongModel(
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

        list.sort((a, b) => a.trackName!.compareTo(b.trackName!));
        setState(() {});
      }
    });
    print(' contador $contrador');
  }

  playLocal(SongModel song) async {
    final String path = await directorio.getPathToDownload();
    _player.stop();
    var result = await _player.setFilePath(path + '/music' + '/${song.nombre}');
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
    setState(() {});
  }
  mostrarViewReproductor(){
    print('hola ${isMostrar} ');
    isMostrar = true;
    setState(() {});
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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          title: Text('Canciones'),
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
                child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return TextButton(
                        onPressed: () {
                          // stopMusic();

                          this.index = index;
                          print('posicion${index}');
                          directorio.mostrar = true;
                          song = list[index];
                          playLocal(song);
                          playing = true;
                          playBtn = Icons.pause;

                          setState(() {});
                        },
                        child: Column(children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Image.memory(
                                list[index].albumArt!,
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
                                        '${list[index].trackName}',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        softWrap: true,
                                        style: TextStyle(color: Colors.white),
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
                    }),
              ),
              directorio.mostrar == true
                  ? Positioned(
                  bottom: 0,
                  child: TextButton(
                    onPressed: () {
                      mostrarViewReproductor();
                    },
                    child: Container(
                      color: Colors.white30,
                      width: width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Image.memory(
                            song.albumArt!,
                            fit: BoxFit.fitWidth,
                            height: 100,
                            width: 100,
                          ),
                          Container(
                              width: width / 2.5,
                              height: 40,
                              child: Center(
                                child: Marquee(
                                  text: song.trackName!,
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
                                      //nextSong(index,list);
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
  const ReproductorView({Key? key}) : super(key: key);

  @override
  State<ReproductorView> createState() => _ReproductorViewState();
}
Stream<PositionData> get _positionDataStream =>
    Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _player.positionStream,
        _player.bufferedPositionStream,
        _player.durationStream,
            (position, bufferedPosition, duration) => PositionData(
            position, bufferedPosition, duration ?? Duration.zero));

class _ReproductorViewState extends State<ReproductorView> {
  void seekToSec(int sec) {
    Duration newPos = Duration(seconds: sec);
    _player.seek(newPos);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Canciones'),
        backgroundColor: Colors.black,
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              setState(() {
                isMostrar = false;
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
              color: Colors.red,
              /*child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Let's add some text title
                  Padding(
                    padding: EdgeInsets.only(left: 50.0),
                    child: Text(
                      "${song.trackName}",
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
                      child: song.albumArt != null
                          ? Image.memory(song.albumArt!)
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
                                              seekToSec(value.toInt());
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
                                onPressed: () {},
                                icon: Icon(
                                  Icons.skip_previous,
                                ),
                              ),
                              IconButton(
                                iconSize: 62.0,
                                color: Colors.black87,
                                onPressed: () {
                                  //here we will add the functionality of the play button
                                  // if (!playing) {
                                  //   //now let's play the song
                                  //   _player.resume();
                                  //   setState(() {
                                  //     playBtn = Icons.pause;
                                  //     print('ppppp ${musicLength} ');
                                  //     playing = true;
                                  //   });
                                  // } else {
                                  //   _player.pause();
                                  //   setState(() {
                                  //     playBtn = Icons.play_arrow;
                                  //     playing = false;
                                  //   });
                                  // }
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
              ),*/
            )),
      ),
    );
  }
}
class a extends StatefulWidget {
  const a({Key? key}) : super(key: key);

  @override
  State<a> createState() => _aState();
}

class _aState extends State<a> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height:MediaQuery.of(context).size.height,
      color: Colors.red,
      child: TextButton(child: Text('BACK'), onPressed: (){
        isMostrar = false;
        setState(() {

        });
      },),
    );
  }
}

