import 'package:diacritic/diacritic.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' as io;
import 'dart:io';

import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:scanner/models/song_model.dart';

class ProviderDirectorio with ChangeNotifier, DiagnosticableTreeMixin {
  bool mostrar = false;
   List<SongModel> _list =[];
  List<SongModel> get list => _list;
  Future<String> getPathToDownload() async {
    return ExtStorage.getExternalStoragePublicDirectory(
        ExtStorage.DIRECTORY_DOWNLOADS);
  }

  ordenar(){
    _list.sort((a, b) => a.trackName!.compareTo(b.trackName!));
    notifyListeners();

  }
}
