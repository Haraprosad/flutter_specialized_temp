
import 'package:flutter/material.dart';
import 'package:flutter_specialized_temp/core/localization/extension/loc.dart';

class FlutterErrorScreen extends StatelessWidget {
  const FlutterErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
      return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.red,
      title: Text(context.loc.error_unknown),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 80, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            context.loc.error_unknown,
            style: TextStyle(fontSize: 18, color: Colors.black),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            context.loc.try_again,
            style: TextStyle(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
  }
}