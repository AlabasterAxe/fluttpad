import 'package:flutter/material.dart';

import 'launchpad.dart';

class LaunchpadViewer extends StatefulWidget {
  final Launchpad launchpad;
  const LaunchpadViewer({super.key, required this.launchpad});

  @override
  State<LaunchpadViewer> createState() => _LaunchpadViewerState();
}

class _LaunchpadViewerState extends State<LaunchpadViewer> {
  @override
  void initState() {
    super.initState();

    widget.launchpad.events().listen((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
        crossAxisCount: 9,
        children: [
          for (var y = 8; y >= 0; y--)
            for (var x = 0; x < 9; x++)
              Container(
                color: widget.launchpad.getColor(x, y).color,
              ),
        ]);
  }
}
