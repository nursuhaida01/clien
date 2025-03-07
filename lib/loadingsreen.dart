import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  final Future<void> Function() onComplete;

  const LoadingScreen({Key? key, required this.onComplete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Start the loading process when this screen is built
    _loadData(context);

    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> _loadData(BuildContext context) async {
    // Perform the fetch operations here
    await onComplete();

    // Navigate back to the previous screen after the data is loaded
    Navigator.of(context).pop();
  }
}
