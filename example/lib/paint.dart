import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_launchpad/colors.dart';
import 'package:flutter_launchpad/launchpad_controller.dart';
import 'package:flutter_launchpad/launchpad_event.dart';
import 'package:flutter_launchpad/viewer.dart';

class PaintPage extends StatelessWidget {
  final LaunchpadController launchpad;

  const PaintPage(this.launchpad, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paint'),
      ),
      body: PaintApplication(launchpad),
    );
  }
}

class PaintApplication extends StatefulWidget {
  final LaunchpadController launchpad;

  const PaintApplication(this.launchpad, {super.key});

  @override
  PaintApplicationState createState() {
    return PaintApplicationState();
  }
}

const COLOR_CYCLE = <LaunchpadColor>[
  LaunchpadColor.OFF,
  LaunchpadColor.WHITE,
  LaunchpadColor.RED_1,
  LaunchpadColor.ORANGE_1,
  LaunchpadColor.YELLOW_1,
  LaunchpadColor.GREEN_1,
  LaunchpadColor.TEAL_1,
  LaunchpadColor.BLUE_1,
  LaunchpadColor.PURPLE_1
];

class PaintApplicationState extends State<PaintApplication> {
  StreamSubscription? _rxSubscription;

  var _currentColor = LaunchpadColor.WHITE;

  @override
  void didChangeDependencies() {
    this._rxSubscription?.cancel();
    this._rxSubscription =
        this.widget.launchpad.events().listen(this._handleEvent);
    this._initializePad();
    super.didChangeDependencies();
  }

  _initializePad() {
    for (var x = 0; x < 10; x++) {
      for (var y = 0; y < 10; y++) {
        if (x == 8) {
          if (y == 8) {
            this.widget.launchpad.setColor(x, y, this._currentColor);
          } else if (y == 7) {
            this.widget.launchpad.setColor(x, y, LaunchpadColor.WHITE);
          } else if (y == 6) {
            this.widget.launchpad.setColor(x, y, LaunchpadColor.RED_1);
          } else if (y == 5) {
            this.widget.launchpad.setColor(x, y, LaunchpadColor.ORANGE_1);
          } else if (y == 4) {
            this.widget.launchpad.setColor(x, y, LaunchpadColor.YELLOW_1);
          } else if (y == 3) {
            this.widget.launchpad.setColor(x, y, LaunchpadColor.GREEN_1);
          } else if (y == 2) {
            this.widget.launchpad.setColor(x, y, LaunchpadColor.TEAL_1);
          } else if (y == 1) {
            this.widget.launchpad.setColor(x, y, LaunchpadColor.BLUE_1);
          } else if (y == 0) {
            this.widget.launchpad.setColor(x, y, LaunchpadColor.PURPLE_1);
          }
        } else {
          this.widget.launchpad.setColor(x, y, LaunchpadColor.OFF);
        }
      }
    }
  }

  _handleXYClick(int x, int y) {
    if (x < 8 && y < 8) {
      final color = this.widget.launchpad.getColor(x, y);
      if (color == this._currentColor) {
        this.widget.launchpad.setColor(x, y, LaunchpadColor.OFF);
      } else {
        this.widget.launchpad.setColor(x, y, this._currentColor);
      }
      return;
    }

    if (x == 8) {
      switch (y) {
        case 7:
          this._currentColor = LaunchpadColor.WHITE;
          break;
        case 6:
          this._currentColor = LaunchpadColor.RED_1;
          break;
        case 5:
          this._currentColor = LaunchpadColor.ORANGE_1;
          break;
        case 4:
          this._currentColor = LaunchpadColor.YELLOW_1;
          break;
        case 3:
          this._currentColor = LaunchpadColor.GREEN_1;
          break;
        case 2:
          this._currentColor = LaunchpadColor.TEAL_1;
          break;
        case 1:
          this._currentColor = LaunchpadColor.BLUE_1;
          break;
        case 0:
          this._currentColor = LaunchpadColor.PURPLE_1;
          break;
      }
      this.widget.launchpad.setColor(8, 8, this._currentColor);
    }
  }

  _handleEvent(LaunchpadEvent event) {
    if (kDebugMode) {
      print('received packet ${event.x}, ${event.y}, ${event.type}');
    }

    if (event.type == LaunchpadEventType.padUp) {
      return;
    }

    this._handleXYClick(event.x, event.y);
  }

  @override
  void initState() {
    if (kDebugMode) {
      print('init controller');
    }
    _rxSubscription = this.widget.launchpad.events().listen(this._handleEvent);

    super.initState();
  }

  @override
  void dispose() {
    // _setupSubscription?.cancel();
    _rxSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LaunchpadViewer(
        launchpad: this.widget.launchpad, onTap: this._handleXYClick);
  }
}

class SteppedSelector extends StatelessWidget {
  final String label;
  final int minValue;
  final int maxValue;
  final int value;
  final Function(int) callback;

  const SteppedSelector(
      this.label, this.value, this.minValue, this.maxValue, this.callback,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(label),
        IconButton(
            icon: const Icon(Icons.remove_circle),
            onPressed: (value > minValue)
                ? () {
                    callback(value - 1);
                  }
                : null),
        Text(value.toString()),
        IconButton(
            icon: const Icon(Icons.add_circle),
            onPressed: (value < maxValue)
                ? () {
                    callback(value + 1);
                  }
                : null)
      ],
    );
  }
}
