import 'dart:typed_data';

class SongModel {
  String? nombre;
  String? path;
  String? trackName;
  String? albumName;
  String? albumArtistName;
  int? trackNumber;
  int? albumLength;
  int? year;
  String? genre;
  String? authorName;
  String? writerName;
  int? discNumber;
  String? mimeType;
  int? trackDuration;
  int? bitrate;
  Uint8List? albumArt;

  SongModel({
    this.nombre,
    this.path,
    this.trackName,
    this.albumName,
    this.albumArtistName,
    this.trackNumber,
    this.albumLength,
    this.year,
    this.genre,
    this.authorName,
    this.writerName,
    this.discNumber,
    this.mimeType,
    this.trackDuration,
    this.bitrate,
    this.albumArt,
  });
}