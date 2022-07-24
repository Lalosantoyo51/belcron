import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:scanner/pages/descargas.dart';
import 'package:scanner/pages/sons.dart';
import 'package:scanner/pages/webview.dart';
import 'package:scanner/provider/provider_derectorio.dart';
import 'package:scanner/provider/provider_download.dart';
import 'package:scanner/provider/provider_reproductor.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:scanner/models/song_model.dart';
import 'dart:io' as io;
import 'dart:io';
import 'package:marquee/marquee.dart';
import 'package:scanner/widgets/seekbar.dart';
import 'package:rxdart/rxdart.dart';
import 'package:audio_session/audio_session.dart';


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
  late ProviderReproductor reproductor;
  @override
  void initState() {

    directorio = Provider.of<ProviderDirectorio>(context, listen: false);
    reproductor = Provider.of<ProviderReproductor>(context, listen: false);
    WidgetsBinding.instance?.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));

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

    super.initState();
  }

  // init() async {
  //   final String path = await directorio.getPathToDownload();
  //
  //   await obtenerCanciones();
  //   // Inform the operating system of our app's audio attributes etc.
  //   // We pick a reasonable default for an app that plays speech.
  //
  //   final session = await AudioSession.instance;
  //   await session.configure(AudioSessionConfiguration.speech());
  //   // Listen to errors during playback.
  //   _player.playbackEventStream.listen((event) {},
  //       onError: (Object e, StackTrace stackTrace) {
  //     print('A stream error occurred: $e');
  //   });
  // }
  //agregar tripulante
  //checar comentarios

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    // Release decoders and buffers back to the operating system making them
    // available for other apps to use.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final downlaod = Provider.of<DownloadProvider>(context);
    final reproductor = Provider.of<ProviderReproductor>(context);
    downlaod.obtenerContador();
    reproductor.obtenerCanciones();
    return Scaffold(
      body: [
        WebView(),
        DescargasPage(),
        // const ReproductorPague(),
        reproductor.isMostrar == false ? SonsView() : ReproductorView()
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



