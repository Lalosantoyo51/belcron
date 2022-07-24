import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scanner/pages/home.dart';
import 'package:scanner/provider/provider_derectorio.dart';
import 'package:scanner/provider/provider_download.dart';
import 'package:scanner/provider/provider_reproductor.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => DownloadProvider()),
            ChangeNotifierProvider(create: (_) => ProviderDirectorio()),
            ChangeNotifierProvider(create: (_) => ProviderReproductor()),
          ],
          child: Home()),
    );
  }
}

// This is a minimal example demonstrating a play/pause button and a seek bar.
// More advanced examples demonstrating other features can be found in the same
// directory as this example in the GitHub repository.

// import 'package:audio_session/audio_session.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:rxdart/rxdart.dart';
// import 'dart:math';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
//   final _player = AudioPlayer();
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance?.addObserver(this);
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//       statusBarColor: Colors.black,
//     ));
//     _init();
//   }
//
//   Future<void> _init() async {
//     // Inform the operating system of our app's audio attributes etc.
//     // We pick a reasonable default for an app that plays speech.
//     final session = await AudioSession.instance;
//     await session.configure(AudioSessionConfiguration.speech());
//     // Listen to errors during playback.
//     _player.playbackEventStream.listen((event) {},
//         onError: (Object e, StackTrace stackTrace) {
//           print('A stream error occurred: $e');
//         });
//     // Try to load audio from a source and catch any errors.
//     try {
//       await _player.setFilePath('/storage/emulated/0/Download/music/Un_gran_caso_de_solidaridad_en_medio_de_la_barbarie_del_estadio_La_Corregidora.mp3');
//     } catch (e) {
//       print("Error loading audio source: $e");
//     }
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance?.removeObserver(this);
//     // Release decoders and buffers back to the operating system making them
//     // available for other apps to use.
//     _player.dispose();
//     super.dispose();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.paused) {
//       // Release the player's resources when not in use. We use "stop" so that
//       // if the app resumes later, it will still remember what position to
//       // resume from.
//       _player.stop();
//     }
//   }
//
//   /// Collects the data useful for displaying in a seek bar, using a handy
//   /// feature of rx_dart to combine the 3 streams of interest into one.
//   Stream<PositionData> get _positionDataStream =>
//       Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
//           _player.positionStream,
//           _player.bufferedPositionStream,
//           _player.durationStream,
//               (position, bufferedPosition, duration) => PositionData(
//               position, bufferedPosition, duration ?? Duration.zero));
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         body: SafeArea(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Display play/pause button and volume/speed sliders.
//               ControlButtons(_player),
//               // Display seek bar. Using StreamBuilder, this widget rebuilds
//               // each time the position, buffered position or duration changes.
//               StreamBuilder<PositionData>(
//                 stream: _positionDataStream,
//                 builder: (context, snapshot) {
//                   final positionData = snapshot.data;
//                   return SeekBar(
//                     duration: positionData?.duration ?? Duration.zero,
//                     position: positionData?.position ?? Duration.zero,
//                     bufferedPosition:
//                     positionData?.bufferedPosition ?? Duration.zero,
//                     onChangeEnd: _player.seek,
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// /// Displays the play/pause button and volume/speed sliders.
// class ControlButtons extends StatelessWidget {
//   final AudioPlayer player;
//
//   ControlButtons(this.player);
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         // Opens volume slider dialog
//         IconButton(
//           icon: Icon(Icons.volume_up),
//           onPressed: () {
//             showSliderDialog(
//               context: context,
//               title: "Adjust volume",
//               divisions: 10,
//               min: 0.0,
//               max: 1.0,
//               value: player.volume,
//               stream: player.volumeStream,
//               onChanged: player.setVolume,
//             );
//           },
//         ),
//
//         /// This StreamBuilder rebuilds whenever the player state changes, which
//         /// includes the playing/paused state and also the
//         /// loading/buffering/ready state. Depending on the state we show the
//         /// appropriate button or loading indicator.
//         StreamBuilder<PlayerState>(
//           stream: player.playerStateStream,
//           builder: (context, snapshot) {
//             final playerState = snapshot.data;
//             final processingState = playerState?.processingState;
//             final playing = playerState?.playing;
//             if (processingState == ProcessingState.loading ||
//                 processingState == ProcessingState.buffering) {
//               return Container(
//                 margin: EdgeInsets.all(8.0),
//                 width: 64.0,
//                 height: 64.0,
//                 child: CircularProgressIndicator(),
//               );
//             } else if (playing != true) {
//               return IconButton(
//                 icon: Icon(Icons.play_arrow),
//                 iconSize: 64.0,
//                 onPressed: (){
//
//                   player.play();
//                 },
//               );
//             } else if (processingState != ProcessingState.completed) {
//               return IconButton(
//                 icon: Icon(Icons.pause),
//                 iconSize: 64.0,
//                 onPressed: (){
//                   player.setFilePath('/storage/emulated/0/Download/a.mp3');
//                   player.stop();
//                   player.play();
//                 },
//               );
//             } else {
//               return IconButton(
//                 icon: Icon(Icons.replay),
//                 iconSize: 64.0,
//                 onPressed: () => player.seek(Duration.zero),
//               );
//             }
//           },
//         ),
//         // Opens speed slider dialog
//         StreamBuilder<double>(
//           stream: player.speedStream,
//           builder: (context, snapshot) => IconButton(
//             icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
//                 style: TextStyle(fontWeight: FontWeight.bold)),
//             onPressed: () {
//               showSliderDialog(
//                 context: context,
//                 title: "Adjust speed",
//                 divisions: 10,
//                 min: 0.5,
//                 max: 1.5,
//                 value: player.speed,
//                 stream: player.speedStream,
//                 onChanged: player.setSpeed,
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
/*

 import 'dart:async';

 import 'package:audio_service/audio_service.dart';
 import 'package:flutter/foundation.dart';
 import 'package:flutter/material.dart';
 import 'package:just_audio/just_audio.dart';
 import 'package:rxdart/rxdart.dart';
 import 'package:scanner/pages/home.dart';

 // You might want to provide this using dependency injection rather than a
 // global variable.
 late AudioHandler _audioHandler;

 Future<void> main() async {
   _audioHandler = await AudioService.init(
     builder: () => AudioPlayerHandler('/storage/emulated/0/Download/music/Un_gran_caso_de_solidaridad_en_medio_de_la_barbarie_del_estadio_La_Corregidora.mp3'),
     config: const AudioServiceConfig(
       androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
       androidNotificationChannelName: 'Audio playback',
       androidNotificationOngoing: true,
     ),
   );
   runApp(const MyApp());
 }

 class MyApp extends StatelessWidget {
   const MyApp({Key? key}) : super(key: key);

   @override
   Widget build(BuildContext context) {
     return MaterialApp(
       title: 'Audio Service Demo',
       theme: ThemeData(primarySwatch: Colors.blue),
       home: const MainScreen(),
     );
   }
 }

 class MainScreen extends StatefulWidget {
   const MainScreen({Key? key}) : super(key: key);

   @override
   State<MainScreen> createState() => _MainScreenState();
 }

 class _MainScreenState extends State<MainScreen> {
   @override
   void initState() {
     // TODO: implement initState
     _mediaStateStream.listen((event) {
       print('${event.position}');
     });

     super.initState();
   }


   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         title: const Text('Audio Service Demo'),
       ),
       body: Center(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             // Show media item title
             StreamBuilder<MediaItem?>(
               stream: _audioHandler.mediaItem,
               builder: (context, snapshot) {
                 final mediaItem = snapshot.data;
                 return Text(mediaItem?.title ?? '');
               },
             ),
             // Play/pause/stop buttons.
             StreamBuilder<bool>(
               stream: _audioHandler.playbackState
                   .map((state) => state.playing)
                   .distinct(),
               builder: (context, snapshot) {
                 final playing = snapshot.data ?? false;
                 return Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     _button(Icons.info, _audioHandler.rewind),
                     if (playing)
                       _button(Icons.pause, _audioHandler.pause)
                     else
                       _button(Icons.play_arrow, _audioHandler.play),
                     _button(Icons.stop, _audioHandler.stop),
                     _button(Icons.fast_forward, (){
                       // _audioHandler.onTaskRemoved();
                       // _audioHandler.stop();
                       //_audioHandler =  AudioPlayerHandler('/storage/emulated/0/Download/a.mp3');
                       //_audioHandler.play();
                       _audioHandler.skipToNext();

                     }),
                   ],
                 );
               },
             ),
             // A seek bar.
             // StreamBuilder<MediaState>(
             //   stream: _mediaStateStream,
             //   builder: (context, snapshot) {
             //     final mediaState = snapshot.data;
             //     return SeekBar(
             //       duration: mediaState?.mediaItem?.duration ?? Duration.zero,
             //       position: mediaState?.position ?? Duration.zero,
             //       onChangeEnd: (newPosition) {
             //         _audioHandler.seek(newPosition);
             //       },
             //     );
             //   },
             // ),
             // Display the processing state.
             StreamBuilder<AudioProcessingState>(
               stream: _audioHandler.playbackState
                   .map((state) => state.processingState)
                   .distinct(),
               builder: (context, snapshot) {
                 final processingState =
                     snapshot.data ?? AudioProcessingState.idle;
                 return Text(
                     "Processing state: ${describeEnum(processingState)}");
               },
             ),
           ],
         ),
       ),
     );
   }

   /// A stream reporting the combined state of the current media item and its
   /// current position.
   Stream<MediaState> get _mediaStateStream =>
       Rx.combineLatest2<MediaItem?, Duration, MediaState>(
           _audioHandler.mediaItem,
           AudioService.position,
               (mediaItem, position) => MediaState(mediaItem, position));

   IconButton _button(IconData iconData, VoidCallback onPressed) => IconButton(
     icon: Icon(iconData),
     iconSize: 64.0,
     onPressed: onPressed,
   );
 }

 class MediaState {
   final MediaItem? mediaItem;
   final Duration position;

   MediaState(this.mediaItem, this.position);
 }

 /// An [AudioHandler] for playing a single item.
 class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {

   static final _item = MediaItem(
     id: 'https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3',
     album: "Science Friday",
     title: "A Salute To Head-Scratching Science",
     artist: "Science Friday and WNYC Studios",
     duration: const Duration(milliseconds: 5739820),
     artUri: Uri.parse(
         'https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg'),
   );


   final player = AudioPlayer();

   /// Initialise our audio handler.
   AudioPlayerHandler(a) {
     print('$a');
     // So that our clients (the Flutter UI and the system notification) know
     // what state to display, here we set up our audio handler to broadcast all
     // playback state changes as they happen via playbackState...
     player.playbackEventStream.map(_transformEvent).pipe(playbackState);
     // ... and also the current media item via mediaItem.
     mediaItem.add(_item);

     // Load the player.
     player.setFilePath(a);
   }

   // In this simple example, we handle only 4 actions: play, pause, seek and
   // stop. Any button press from the Flutter UI, notification, lock screen or
   // headset will be routed through to these 4 methods so that you can handle
   // your audio playback logic in one place.

   @override
   Future<void> play() => player.play();
   
   
   @override
   Future<void>skipToNext(){
     player.setFilePath('/storage/emulated/0/Download/a.mp3');
     return player.play();
   }

   @override
   Future<void> pause() {
     print('hola ');
     return player.pause();
   }

   @override
   Future<void> seek(Duration position) => player.seek(position);

   @override
   Future<void> stop() => player.stop();

   /// Transform a just_audio event into an audio_service state.
   ///
   /// This method is used from the constructor. Every event received from the
   /// just_audio player will be transformed into an audio_service state so that
   /// it can be broadcast to audio_service clients.
   PlaybackState _transformEvent(PlaybackEvent event) {
     return PlaybackState(
       controls: [
         MediaControl.rewind,
         if (player.playing) MediaControl.pause else MediaControl.play,
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
       }[player.processingState]!,
       playing: player.playing,
       updatePosition: player.position,
       bufferedPosition: player.bufferedPosition,
       speed: player.speed,
       queueIndex: event.currentIndex,
     );
   }
 }*/


// class SeekBar extends StatefulWidget {
//   final Duration duration;
//   final Duration position;
//   final Duration bufferedPosition;
//   final ValueChanged<Duration>? onChanged;
//   final ValueChanged<Duration>? onChangeEnd;
//
//   SeekBar({
//     required this.duration,
//     required this.position,
//     required this.bufferedPosition,
//     this.onChanged,
//     this.onChangeEnd,
//   });
//
//   @override
//   _SeekBarState createState() => _SeekBarState();
// }
//
// class _SeekBarState extends State<SeekBar> {
//   double? _dragValue;
//   late SliderThemeData _sliderThemeData;
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//
//     _sliderThemeData = SliderTheme.of(context).copyWith(
//       trackHeight: 2.0,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         SliderTheme(
//           data: _sliderThemeData.copyWith(
//             thumbShape: HiddenThumbComponentShape(),
//             activeTrackColor: Colors.blue.shade100,
//             inactiveTrackColor: Colors.grey.shade300,
//           ),
//           child: ExcludeSemantics(
//             child: Slider(
//               min: 0.0,
//               max: widget.duration.inMilliseconds.toDouble(),
//               value: min(widget.bufferedPosition.inMilliseconds.toDouble(),
//                   widget.duration.inMilliseconds.toDouble()),
//               onChanged: (value) {
//                 setState(() {
//                   _dragValue = value;
//                 });
//                 if (widget.onChanged != null) {
//                   widget.onChanged!(Duration(milliseconds: value.round()));
//                 }
//               },
//               onChangeEnd: (value) {
//                 if (widget.onChangeEnd != null) {
//                   widget.onChangeEnd!(Duration(milliseconds: value.round()));
//                 }
//                 _dragValue = null;
//               },
//             ),
//           ),
//         ),
//         SliderTheme(
//           data: _sliderThemeData.copyWith(
//             inactiveTrackColor: Colors.transparent,
//           ),
//           child: Slider(
//             min: 0.0,
//             max: widget.duration.inMilliseconds.toDouble(),
//             value: min(_dragValue ?? widget.position.inMilliseconds.toDouble(),
//                 widget.duration.inMilliseconds.toDouble()),
//             onChanged: (value) {
//               setState(() {
//                 _dragValue = value;
//               });
//               if (widget.onChanged != null) {
//                 widget.onChanged!(Duration(milliseconds: value.round()));
//               }
//             },
//             onChangeEnd: (value) {
//               if (widget.onChangeEnd != null) {
//                 widget.onChangeEnd!(Duration(milliseconds: value.round()));
//               }
//               _dragValue = null;
//             },
//           ),
//         ),
//         Positioned(
//           right: 16.0,
//           bottom: 0.0,
//           child: Text(
//               RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
//                   .firstMatch("$_remaining")
//                   ?.group(1) ??
//                   '$_remaining',
//               style: Theme.of(context).textTheme.caption),
//         ),
//       ],
//     );
//   }
//
//   Duration get _remaining => widget.duration - widget.position;
// }
//
// class HiddenThumbComponentShape extends SliderComponentShape {
//   @override
//   Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;
//
//   @override
//   void paint(
//       PaintingContext context,
//       Offset center, {
//         required Animation<double> activationAnimation,
//         required Animation<double> enableAnimation,
//         required bool isDiscrete,
//         required TextPainter labelPainter,
//         required RenderBox parentBox,
//         required SliderThemeData sliderTheme,
//         required TextDirection textDirection,
//         required double value,
//         required double textScaleFactor,
//         required Size sizeWithOverflow,
//       }) {}
// }
//
// class PositionData {
//   final Duration position;
//   final Duration bufferedPosition;
//   final Duration duration;
//
//   PositionData(this.position, this.bufferedPosition, this.duration);
// }
//
// void showSliderDialog({
//   required BuildContext context,
//   required String title,
//   required int divisions,
//   required double min,
//   required double max,
//   String valueSuffix = '',
//   // TODO: Replace these two by ValueStream.
//   required double value,
//   required Stream<double> stream,
//   required ValueChanged<double> onChanged,
// }) {
//   showDialog<void>(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: Text(title, textAlign: TextAlign.center),
//       content: StreamBuilder<double>(
//         stream: stream,
//         builder: (context, snapshot) => Container(
//           height: 100.0,
//           child: Column(
//             children: [
//               Text('${snapshot.data?.toStringAsFixed(1)}$valueSuffix',
//                   style: TextStyle(
//                       fontFamily: 'Fixed',
//                       fontWeight: FontWeight.bold,
//                       fontSize: 24.0)),
//               Slider(
//                 divisions: divisions,
//                 min: min,
//                 max: max,
//                 value: snapshot.data ?? value,
//                 onChanged: onChanged,
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }
