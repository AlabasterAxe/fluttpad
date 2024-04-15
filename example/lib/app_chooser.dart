import 'package:flutter/material.dart';

import 'shortcuts.dart';
import 'package:flutter_launchpad/launchpad_controller.dart';
import 'paint.dart';

class AppChooser extends StatelessWidget {
  final LaunchpadController launchpad;
  const AppChooser({super.key, required this.launchpad});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose App'),
      ),
      body: GridView.count(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PaintPage(launchpad)));
              },
              child: Container(
                color: Colors.red,
                child: const Center(child: Text('Paint')),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ShortcutsPage(launchpad)));
              },
              child: Container(
                color: Colors.amber,
                child: const Center(child: Text('Shortcuts')),
              ),
            ),
          ]),
    );
  }
}
