import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MobileLoading extends StatelessWidget {
  const MobileLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Lottie.asset('assets/lotties/loading.json'));
  }
}
