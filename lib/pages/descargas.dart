import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/provider.dart';
import 'package:scanner/provider/provider_derectorio.dart';
import 'package:scanner/provider/provider_download.dart';
import 'package:scanner/provider/provider_reproductor.dart';

class DescargasPage extends StatefulWidget {
  const DescargasPage({Key? key}) : super(key: key);

  @override
  _DescargasPageState createState() => _DescargasPageState();
}

class _DescargasPageState extends State<DescargasPage> {
  @override
  Widget build(BuildContext context) {
    final download = Provider.of<DownloadProvider>(context);
    double  width= MediaQuery.of(context).size.width;
    double  height= MediaQuery.of(context).size.height;
    return Container(
      child: Scaffold(
        appBar: AppBar(centerTitle: true,title: const Text('Descargas'),backgroundColor: Colors.black,),
        backgroundColor: Colors.black87,
        body: download.downloads.isNotEmpty? Padding(
          padding: const EdgeInsets.only(left: 20,right: 20,top: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child:Text('Nombre',style: TextStyle(color: Colors.white),),
                  ),
                  Container(
                    child:const Text('Status',style: TextStyle(color: Colors.white),),
                  ),
                ],
              ),
              Container(
                height: height/1.4,
                child: ListView.builder(itemCount: download.downloads.length,itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width/ 1.5,
                              child:Text(' ${download.downloads[index].nombre}',style: TextStyle(color: Colors.white),),
                            ),
                            download.downloads[index].status == 'progreso'?
                            Container(
                              child:Text(' ${download.downloads[index].progres}%',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                            ):download.downloads[index].status == 'descargado'?
                            Container(
                              child:Icon(Icons.check_circle,color: Colors.green,)
                            ):
                              Container(
                              child:Text(' ${download.downloads[index].status}',style: TextStyle(color: Colors.white),),
                            )
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ):Center(child: Text('No tienes descargas pendientes',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),),),
      ),
    );
  }
}
