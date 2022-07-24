import 'package:flutter/material.dart';

class LoadingAlert extends StatefulWidget {
  String messageAler;
  LoadingAlert(this.messageAler);
  @override
  _LoadingAlertState createState() => _LoadingAlertState();
}

class _LoadingAlertState extends State<LoadingAlert> {
  @override
  Widget build(BuildContext context) {
    var sizeWidth = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return AlertDialog(
      content: Container(
        width: sizeWidth/2,
        height: height/20,
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[

                Container(
                  height: height/20,
                  width: sizeWidth/15,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.red,
                  ),
                ),
                Container(
                  child: Text(
                    "    ${widget.messageAler}",
                    style: TextStyle(),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
