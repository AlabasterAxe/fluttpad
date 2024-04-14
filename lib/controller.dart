import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_midi_command/flutter_midi_command_messages.dart';
import 'colors.dart';
import 'launchpad.dart';

class ControllerPage extends StatelessWidget {
  final Launchpad launchpad;

  const ControllerPage(this.launchpad, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controls'),
      ),
      body: PaintApplication(launchpad),
    );
  }
}

class PaintApplication extends StatefulWidget {
  final Launchpad launchpad;

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
  var _channel = 0;
  var _controller = 0;
  var _ccValue = 0;
  var _pcValue = 0;
  var _pitchValue = 0.0;
  var _nrpnValue = 0;
  var _nrpnCtrl = 0;

  // StreamSubscription<String> _setupSubscription;
  StreamSubscription<MidiPacket>? _rxSubscription;

  final _gridColors = <int, int>{};

  var _currentColor = LaunchpadColor.WHITE;

  @override
  void didChangeDependencies() {
    this._rxSubscription?.cancel();
    this._rxSubscription =
        this.widget.launchpad.events().listen(this._handleMessage);
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

  _handleMessage(packet) {
    if (kDebugMode) {
      print('received packet $packet');
    }
    var data = packet.data;
    var timestamp = packet.timestamp;
    var device = packet.device;
    if (kDebugMode) {
      print(
          "data $data @ time $timestamp from device ${device.name}:${device.id}");
    }

    if (data.length > 2 && data[2] == 127) {
      _gridColors[data[1]] =
          ((_gridColors[data[1]] ?? 0) + 1) % COLOR_CYCLE.length;
      final i = data[1];
      if (i == 89) {
        this._currentColor = LaunchpadColor.WHITE;
        this.widget.launchpad.setColor_midiAddress(99, this._currentColor);
      } else if (i == 79) {
        this._currentColor = LaunchpadColor.RED_1;
        this.widget.launchpad.setColor_midiAddress(99, this._currentColor);
      } else if (i == 69) {
        this._currentColor = LaunchpadColor.ORANGE_1;
        this.widget.launchpad.setColor_midiAddress(99, this._currentColor);
      } else if (i == 59) {
        this._currentColor = LaunchpadColor.YELLOW_1;
        this.widget.launchpad.setColor_midiAddress(99, this._currentColor);
      } else if (i == 49) {
        this._currentColor = LaunchpadColor.GREEN_1;
        this.widget.launchpad.setColor_midiAddress(99, this._currentColor);
      } else if (i == 39) {
        this._currentColor = LaunchpadColor.TEAL_1;
        this.widget.launchpad.setColor_midiAddress(99, this._currentColor);
      } else if (i == 29) {
        this._currentColor = LaunchpadColor.BLUE_1;
        this.widget.launchpad.setColor_midiAddress(99, this._currentColor);
      } else if (i == 19) {
        this._currentColor = LaunchpadColor.PURPLE_1;
        this.widget.launchpad.setColor_midiAddress(99, this._currentColor);
      } else {
        this.widget.launchpad.setColor_midiAddress(i, this._currentColor);
      }
    }

    var status = data[0];

    if (status == 0xF8) {
      // Beat
      return;
    }

    if (status == 0xFE) {
      // Active sense;
      return;
    }

    if (data.length >= 2) {
      var rawStatus = status & 0xF0; // without channel
      var channel = (status & 0x0F);
      if (channel == _channel) {
        var d1 = data[1];
        switch (rawStatus) {
          case 0xB0: // CC
            if (d1 == _controller) {
              // CC
              var d2 = data[2];
              setState(() {
                _ccValue = d2;
              });
            }
            break;
          case 0xC0: // PC
            setState(() {
              _pcValue = d1;
            });
            break;
          case 0xE0: // Pitch Bend
            setState(() {
              var rawPitch = d1 + (data[2] << 7);
              _pitchValue = (((rawPitch) / 0x3FFF) * 2.0) - 1;
            });
            break;
        }
      }
    }
  }

  @override
  void initState() {
    if (kDebugMode) {
      print('init controller');
    }
    _rxSubscription =
        this.widget.launchpad.events().listen(this._handleMessage);

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
    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        Text("Channel", style: Theme.of(context).textTheme.titleLarge),
        SteppedSelector('Channel', _channel + 1, 1, 16, _onChannelChanged),
        const Divider(),
        Text("CC", style: Theme.of(context).textTheme.titleLarge),
        SteppedSelector(
            'Controller', _controller, 0, 127, _onControllerChanged),
        SlidingSelector('Value', _ccValue, 0, 127, _onValueChanged),
        const Divider(),
        Text("NRPN", style: Theme.of(context).textTheme.titleLarge),
        SteppedSelector('Parameter', _nrpnCtrl, 0, 16383, _onNRPNCtrlChanged),
        SlidingSelector('Parameter', _nrpnCtrl, 0, 16383, _onNRPNCtrlChanged),
        SlidingSelector('Value', _nrpnValue, 0, 16383, _onNRPNValueChanged),
        const Divider(),
        Text("PC", style: Theme.of(context).textTheme.titleLarge),
        SteppedSelector('Program', _pcValue, 0, 127, _onProgramChanged),
        const Divider(),
        Text("Pitch Bend", style: Theme.of(context).textTheme.titleLarge),
        Slider(
            value: _pitchValue,
            max: 1,
            min: -1,
            onChanged: _onPitchChanged,
            onChangeEnd: (_) {
              _onPitchChanged(0);
            }),
      ],
    );
  }

  _onChannelChanged(int newValue) {
    setState(() {
      _channel = newValue - 1;
    });
  }

  _onControllerChanged(int newValue) {
    setState(() {
      _controller = newValue;
    });
  }

  _onProgramChanged(int newValue) {
    setState(() {
      _pcValue = newValue;
    });
    PCMessage(channel: _channel, program: _pcValue).send();
  }

  _onValueChanged(int newValue) {
    setState(() {
      _ccValue = newValue;
    });
    CCMessage(channel: _channel, controller: _controller, value: _ccValue)
        .send();
  }

  _onNRPNValueChanged(int newValue) {
    setState(() {
      _nrpnValue = newValue;
    });
    NRPN4Message(channel: _channel, parameter: _nrpnCtrl, value: _nrpnValue)
        .send();
  }

  _onNRPNCtrlChanged(int newValue) {
    setState(() {
      _nrpnCtrl = newValue;
    });
  }

  _onPitchChanged(double newValue) {
    setState(() {
      _pitchValue = newValue;
    });
    PitchBendMessage(channel: _channel, bend: _pitchValue).send();
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

class SlidingSelector extends StatelessWidget {
  final String label;
  final int minValue;
  final int maxValue;
  final int value;
  final Function(int) callback;

  const SlidingSelector(
      this.label, this.value, this.minValue, this.maxValue, this.callback,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(label),
        Slider(
          value: value.toDouble(),
          divisions: maxValue,
          min: minValue.toDouble(),
          max: maxValue.toDouble(),
          onChanged: (v) {
            callback(v.toInt());
          },
        ),
        Text(value.toString()),
      ],
    );
  }
}
