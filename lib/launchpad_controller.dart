import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_launchpad/colors.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:rxdart/rxdart.dart';

import 'launchpad_event.dart';
import 'launchpad_models.dart';
import 'launchpad_reader.dart';

class LaunchpadController implements LaunchpadReader {
  final LaunchpadModel model;
  final MidiDevice device;
  final MidiCommand _midiCommand;
  StreamSubscription? _eventSubscription;
  final _colorValues = <int, LaunchpadColor>{};
  final _midiEvents = BehaviorSubject<MidiPacket>();
  LaunchpadController._(
      {required this.model, required this.device, required midiCommand})
      : _midiCommand = midiCommand {
    this._eventSubscription =
        this._midiCommand.onMidiDataReceived?.listen((data) {
      this._midiEvents.add(data);
    });
  }

  dispose() {
    this._eventSubscription?.cancel();
  }

  factory LaunchpadController.fromDevice(
      {required MidiDevice device, required MidiCommand midiCommand}) {
    final model = parseModel(device.name);
    if (model == null) {
      throw Exception("Unknown Launchpad model");
    }
    return LaunchpadController._(
        model: model, device: device, midiCommand: midiCommand);
  }

  get id => device.id;

  get connected => device.connected;

  connect() async {
    if (device.connected) {
      return;
    }
    await this._midiCommand.connectToDevice(device);
  }

  disconnect() {
    this._midiCommand.disconnectDevice(device);
  }

  clear() {
    this._colorValues.clear();
    final data = <int>[240, 0, 32, 41, 2, 13, 3];
    for (var x = 0; x < 9; x++) {
      for (var y = 0; y < 9; y++) {
        data.addAll([0, this._pointToMidiAddress(x, y), 0]);
      }
    }

    data.add(247);
    this._midiCommand.sendData(Uint8List.fromList(data));
  }

  _pointToMidiAddress(int x, int y) {
    if (model == LaunchpadModel.MINI_MK3) {
      return (y + 1) * 10 + x + 1;
    }
    throw Exception("Unknown Launchpad model");
  }

  setColor(int x, int y, LaunchpadColor color,
      [LaunchpadLightMode mode = LaunchpadLightMode.STATIC]) {
    final midiAddress = _pointToMidiAddress(x, y);
    this._colorValues[midiAddress] = color;
    this
        ._midiCommand
        .sendData(Uint8List.fromList([mode.value, midiAddress, color.value]));
  }

  LaunchpadColor getColor(int x, int y) {
    final midiAddress = _pointToMidiAddress(x, y);
    return this._colorValues[midiAddress] ?? LaunchpadColor.OFF;
  }

  Stream<LaunchpadEvent> events() {
    return this._midiEvents.map(
      (event) {
        return LaunchpadEvent(event);
      },
    );
  }
}