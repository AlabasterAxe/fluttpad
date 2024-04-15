import 'package:flutter/material.dart';
import 'package:flutter_launchpad/colors.dart';
import 'package:flutter_launchpad/launchpad_controller.dart';
import 'package:flutter_launchpad/launchpad_layout.dart';
import 'package:flutter_launchpad/viewer.dart';

class ShortcutsPage extends StatelessWidget {
  final LaunchpadController launchpad;

  const ShortcutsPage(this.launchpad, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shortcuts'),
      ),
      body: ShortcutsApplication(launchpad: launchpad),
    );
  }
}

class ShortcutsApplication extends StatefulWidget {
  final LaunchpadController launchpad;
  const ShortcutsApplication({super.key, required this.launchpad});

  @override
  State<ShortcutsApplication> createState() => _ShortcutsApplicationState();
}

class _ShortcutsApplicationState extends State<ShortcutsApplication> {
  late final _layout = LaunchpadLayout(
    launchpad: widget.launchpad,
    pads: [
      LaunchpadPad(color: LaunchpadColor.RED_1, onTap: () => print('Red 1')),
      LaunchpadPad(color: LaunchpadColor.RED_2, onTap: () => print('Red 2')),
      LaunchpadPad(color: LaunchpadColor.RED_2, onTap: () => print('Red 2')),
      LaunchpadPad(color: LaunchpadColor.RED_2, onTap: () => print('Red 2')),
      LaunchpadPad(color: LaunchpadColor.RED_2, onTap: () => print('Red 2')),
      LaunchpadPad(color: LaunchpadColor.RED_2, onTap: () => print('Red 2')),
      LaunchpadPad(color: LaunchpadColor.RED_2, onTap: () => print('Red 2')),
      LaunchpadPad(color: LaunchpadColor.RED_2, onTap: () => print('Red 2')),
      LaunchpadPad(color: LaunchpadColor.RED_2, onTap: () => print('Red 2')),
    ],
    upArrow: LaunchpadPad(
        color: LaunchpadColor.YELLOW_1, onTap: () => print('Up Arrow')),
    sceneButtons: [
      LaunchpadPad(
          color: LaunchpadColor.GREEN_1, onTap: () => print('Scene 1')),
      LaunchpadPad(color: LaunchpadColor.BLUE_1, onTap: () => print('Scene 2')),
    ],
    logo: LaunchpadColor.PALE_INDIGO,
  );

  @override
  Widget build(BuildContext context) {
    return LaunchpadViewer(launchpad: _layout);
  }
}
