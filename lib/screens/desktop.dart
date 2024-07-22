import 'package:flutter/material.dart';

class DesktopView extends StatefulWidget {
  const DesktopView({super.key});

  @override
  _DesktopViewState createState() => _DesktopViewState();
}

class _DesktopViewState extends State<DesktopView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          Text("Desktop View"),
        ],
      ),
    );
  }
}
