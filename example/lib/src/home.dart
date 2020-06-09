import 'package:assets_picker/asset_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Column(children: [
          header,
          Expanded(
            child: Container(
              color: Colors.transparent,
              child: AssetPicker(),
            ),
          )
        ]),
      ),
    );
  }

  Widget get header => Container(
        margin: const EdgeInsets.only(top: 30.0),
        height: 60.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1.0,
              child: Hero(
                tag: 'LOGO',
                child: Image.asset(
                  'assets/ic_launcher.png',
                ),
              ),
            ),
            const SizedBox(width: 10.0),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  ' Asset Picker',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Demo for the package.',
                ),
              ],
            ),
            const SizedBox(width: 20.0),
          ],
        ),
      );
}
