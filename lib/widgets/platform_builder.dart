import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qrpeasy_flutter/screens/desktop.dart';
import 'package:qrpeasy_flutter/screens/mobile.dart';

class PlatformBuilder extends StatelessWidget {
  const PlatformBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS) return const MobileView();
    if (Platform.isWindows) return const DesktopView();
    return const Scaffold(
        body: Center(
      child: SizedBox(
        width: 300,
        height: 110,
        child: Card(
            elevation: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Platform not supported!",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                Text("Sorry, This platform is not supported"),
              ],
            )),
      ),
    ));
  }
}
