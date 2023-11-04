import 'package:flutter/material.dart';

class ChangeThemePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Change Theme"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // TODO: Change the background color of other pages based on user's selection
          },
          child: Text("Change Background Color"),
        ),
      ),
    );
  }
}
