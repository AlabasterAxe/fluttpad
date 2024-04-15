import 'package:flutter/material.dart';
import 'package:flutter_launchpad/launchpad_models.dart';
import 'package:flutter_launchpad/viewer/launchpad_mini_3.dart';

import '../launchpad_controller.dart';
import '../launchpad_reader.dart';

class LaunchpadViewer extends StatelessWidget {
  final LaunchpadReader launchpad;
  final Function(int x, int y)? onTap;
  const LaunchpadViewer({super.key, required this.launchpad, this.onTap});

  @override
  Widget build(BuildContext context) {
    return switch (launchpad.model) {
      LaunchpadModel.MINI_MK3 => LaunchpadMini3(
          launchpad: this.launchpad,
          onTap: this.onTap,
        ),
    };
  }
}
