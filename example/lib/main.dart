import 'package:flutter/material.dart';
import 'package:flutter_launchpad/colors.dart';
import 'package:flutter_launchpad/launchpad_controller.dart';
import 'package:flutter_launchpad/launchpad_service.dart';
import 'package:flutter_launchpad/viewer.dart';

void main() => runApp(const LaunchpadExampleApp());

class LaunchpadExampleApp extends StatefulWidget {
  const LaunchpadExampleApp({super.key});

  @override
  State<LaunchpadExampleApp> createState() => _LaunchpadExampleAppState();
}

class _LaunchpadExampleAppState extends State<LaunchpadExampleApp> {
  // The LaunchpadService is responsible for providing information about any
  // Launchpads that are connected to the system.
  final _launchpadService = LaunchpadService();

  // The LaunchpadController manages the connection to a specific Launchpad.
  late final Future<LaunchpadController?> _launchpad =
      _launchpadService.listLaunchpads().then((value) async {
    final controller = value.firstOrNull;
    if (controller != null) {
      controller.clear();
      if (!controller.connected) {
        await controller.connect();
      }
    }
    return controller;
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FutureBuilder<LaunchpadController?>(
            future: _launchpad,
            builder: (context, snapshot) {
              final controller = snapshot.data;
              if (controller != null) {
                return Center(
                  // The LaunchpadViewer is a widget that displays the current
                  // state. For a higher-level API, see the LaunchpadLayout widget.
                  child: LaunchpadViewer(
                    launchpad: controller,

                    // The onTap callback is called whenever a pad is pressed on the physical Launchpad
                    // or when a pad is pressed on the LaunchpadViewer widget.
                    onTap: (x, y) {
                      // The controller provides the ability to set/get the color of a pad.
                      controller.setColor(x, y, LaunchpadColor.WHITE);
                    },
                  ),
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text('Error loading Launchpad'),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
    );
  }
}
