import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:diacritic/diacritic.dart';
import 'package:dio/dio.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:http/http.dart' as http;
import 'package:scanner/models/download_model.dart';

class DownloadProvider with ChangeNotifier, DiagnosticableTreeMixin {
  late Timer _timer;
  var dio = Dio();
  List<DownloadModel> _downloads = [];
  String _porcentaje = '0';
  int _count = 0;
  int get count => _count;
  List<DownloadModel> get downloads => _downloads;
  int _numDes = 0;
  int get numDes => _numDes;

  String get porcentaje => _porcentaje;
  void increment() {
    _downloads.clear();
    _count++;
    notifyListeners();
  }

  /// Makes `Counter` readable inside the devtools by listing all of its properties
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('count', count));
  }
  //obtener path de descargas

  Future<String> _getPathToDownload() async {
    return ExtStorage.getExternalStoragePublicDirectory(
        ExtStorage.DIRECTORY_DOWNLOADS);
  }

  //obtener los datos del video
  Future getInfoVideo(url,id_video,context) async {
    _porcentaje = '0';
    var response = await dio.get(
        'https://youtube.googleapis.com/youtube/v3/videos?key=AIzaSyA9ZcjodgO58KkRBdY7OojBrBPM-PMuOKY&part=snippet&part=contentDetails&id=$id_video');
    alert(response.data['items'][0]['snippet']['title'], url,id_video,context);
    notifyListeners();

  }

  //mensaje para la descarga
  alert(titulo, url,id_video,context) {
    Alert(
      context: context,
      type: AlertType.success,
      title: "Quieres descargar ",
      desc: "$titulo",
      buttons: [
        DialogButton(
          child: const Text(
            "Aceptar",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
/*
            convertVideo(titulo, url,id_video);
*/
            _downloads.add(DownloadModel(nombre: titulo,id: id_video,progres: '0',status: 'pendiente',url: url));
            checkList();

            Navigator.pop(context);
          },
          width: 120,
        )
      ],
    ).show();
    notifyListeners();
  }
  //convertir video a mp3
  Future convertVideo(titulo,id_video) async {
    print('convierte el video');
    print('la url $id_video');
    var response = await http.get(
        Uri.parse('https://youtube-mp36.p.rapidapi.com/dl?id=$id_video'),
        headers: {
          'X-Rapidapi-Host': 'youtube-mp36.p.rapidapi.com',
          'X-Rapidapi-Key': 'f8bf683cb3msh52a8325cd1498d7p188dd3jsnc7f229402656'
          // 'X-Rapidapi-Key': 'feb875a828mshd259781a1592f6dp13a0f1jsn843dc23adf40' key uno
          // 'X-Rapidapi-Key': 'fa043b5b06mshd1801dec89f4032p1721abjsn60124919a69a' key dos
        });
    print('el response convertVideo ${json.decode(response.body)}');
    if (json.decode(response.body)['link'] != '') {
      setName(json.decode(response.body)['link'],
          json.decode(response.body)['title'],id_video);
    } else {
      _timer = Timer(const Duration(seconds:3),(){
        convertVideo(titulo,id_video);

      });
    }
    notifyListeners();
  }

  //poner nombre al archivo
  setName(urlFile, titulo,id) async {
    _getPathToDownload();
    final String path = await _getPathToDownload();
    print('el pathaaaaa ${path}');
    String newTitulo = titulo
        .toString()
        .replaceAll(' ', '_')
        .replaceAll('"', '')
        .replaceAll("'", '')
        .replaceAll("{", '')
        .replaceAll("}", '')
        .replaceAll("[", '')
        .replaceAll("]", '')
        .replaceAll("~", '')
        .replaceAll("`", '')
        .replaceAll('?', '')
        .replaceAll(':', '')
        .replaceAll('%', '')
        .replaceAll('@', '')
        .replaceAll('#', '')
        .replaceAll('^', '')
        .replaceAll('&', '')
        .replaceAll('*', '')
        .replaceAll('ð', '')
        .replaceAll('¥', '')
        .replaceAll('¶', '')
        .replaceAll('³', '')
        .replaceAll('±', '')
        .replaceAll(r"$", '')
        .replaceAll(';', '')
        .replaceAll('/', '')
        .replaceAll('ñ', 'n')
        .replaceAll('Ñ', 'N')
        .replaceAll('¿', '')
        .replaceAll('|', '');
    await crearCarpeta(path);
    newTitulo = removeDiacritics('$newTitulo');
    String fullPath = path + "/music/${removeDiacritics('$newTitulo')}.mp3";
    print('full path ${fullPath}');
    download(dio, urlFile, fullPath,id);

    notifyListeners();
  }

  // crear la carpeta music en descarfas
  crearCarpeta(path)async{
    /*   final myImagePath = '${directory.path}/MyImages' ;
    final myImgDir = await new Directory(myImagePath).create();*/
    final myImagePath = '$path/music' ;
    final myImgDir = await new Directory(myImagePath).create();
    notifyListeners();
  }

  //descargar archivo mp3
  Future download(Dio dio, String url, String savePath, id_video) async {
    print('empiemza a descargar el archivo');
    try {
      Response response = await dio.get(
        url,
        onReceiveProgress:(received,total)=>showDownloadProgress(received, total, id_video),
        //Received data with List<int>
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );
      print(response.headers);
      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
      raf.writeFromSync(response.data);
      await raf.close();
    } catch (e) {
      print(e);
    }
  }

  //ver progreso de la descarga
  void showDownloadProgress(received, total,id) {
    if (total != -1) {
      print('el progesos $id' + (received / total * 100).toStringAsFixed(0) + "%");
      _porcentaje = (received / total * 100).toStringAsFixed(0);
      //final tile = _downloads.where((item) => item.id == id);
      //tile.first.progres = _porcentaje;
      var donw = _downloads.firstWhere((element) => element.id == id);
      donw.progres = _porcentaje;

      notifyListeners();
      if(_porcentaje == '100'){
        print('entra');
        donw.status = 'descargado';
        _porcentaje= '0';
        checkList();
        notifyListeners();

      }
    }

  }
  //verificar si hay en espera  para pasar a la siguiente descarga
  checkList(){
    //final down =_downloads.firstWhere((element) => element.status == 'progreso');
    //down.status = 'descargado';
    //print('se cambio');

    //final tile = _downloads.where((item) => item.id == id);
    //tile.first.progres = _porcentaje;
    _downloads.forEach((element) {
      print('el nombre ${element.nombre}  ${element.status}');
    });

    var down =_downloads.where((element) => element.status == 'progreso' );

    if(down.isEmpty){
      var down2 =_downloads.where((element) => element.status == 'pendiente' );
      if(down2.isNotEmpty){
        final down3 =down2.first;
        down3.status = 'progreso';
        convertVideo(down3.nombre, down3.id);
        print('entra para la descarga');
      }

    }else{
      print('hay un elemento en descarga');
    }
    notifyListeners();
  }
  obtenerContador(){
    var down =_downloads.where((element) => element.status == 'pendiente'   || element.status == 'progreso');

    if(down.isNotEmpty){
      _numDes = down.length;

    }else{
      _numDes = 0;
    }

  }
  simular(titulo,id_video){
    int contador = 0;
      _timer = Timer.periodic(const Duration(seconds:1), (Timer t){
        contador++;
        var donw = _downloads.firstWhere((element) => element.id == id_video);
        donw.progres = contador.toString();
        if(contador == 10){
          print('se cancela el time $titulo');
          donw.status = 'descargado';
          _timer.cancel();
          checkList();


        }
      });
    notifyListeners();

  }
}