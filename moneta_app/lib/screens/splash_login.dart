import 'package:flutter/material.dart';

// Local-only mode has no login; keep a lightweight landing in case referenced.
class SplashLoginScreen extends StatelessWidget {
  const SplashLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Moneta')));
  }
}
