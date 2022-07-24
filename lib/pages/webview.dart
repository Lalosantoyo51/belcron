import 'package:flutter/material.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/src/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:scanner/provider/provider_download.dart';
import 'package:scanner/widgets/loading.dart';



class WebView extends StatefulWidget {
  const WebView({Key? key}) : super(key: key);

  @override
  _WebViewState createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  late String directory;
  String url = '';
  String id_video = '';


  late InAppWebViewController webView;

  @override
  void initState() {
    // TODO: implement initState
    //getInfoVideo('url');
    //metodo("https://mdelta.123tokyo.xyz/get.php/6/29/UxxajLWwzqY.mp3?cid=MTczLjI0OS4xMC4yMjJ8TkF8REU%3D&h=LfFSJtWMUew_RG3nTTAw6Q&s=1645736516&n=Icona-Pop-I-Love-It-feat-Charli-XCX-OFFICIAL-VIDEO", 'relatos');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Inicio'),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // context.read<DownloadProvider>().increment();
             context.read<DownloadProvider>().getInfoVideo(url, id_video, context);
          },
          child: Icon(Icons.download),
        ),
        body: Stack(
          children: [
            Container(
                child: Column(children: <Widget>[
                  Expanded(
                      child: InAppWebView(
                        initialUrlRequest:
                        URLRequest(url: Uri.parse("https://www.youtube.com/")),
                        onWebViewCreated: (controller) {
                          webView = controller;
                        },
                        onUpdateVisitedHistory:
                            (controller, url, androidIsReload) async {
                          this.url = url.toString();
                          print('la uri ${url}');
                          if (url.toString().contains('https://m.youtube.com/watch?')) {
                            this.url =url.toString();
                            print('mostrar alerta');
                            id_video = url
                                .toString()
                                .replaceAll('https://m.youtube.com/watch?v=', '');
                            context.read<DownloadProvider>().getInfoVideo(url.toString(), id_video, context);

                          }
                        },
                      ))
                ])),


          ],
        ),
      ),
    );
  }
}
