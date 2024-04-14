import 'dart:async';

import 'package:flutter_midi_command/flutter_midi_command.dart';

import 'launchpad-models.dart' show parseModel;
import 'launchpad.dart';
import 'package:rxdart/rxdart.dart';

class LaunchpadController {
  final MidiCommand _midiCommand = MidiCommand();
  final _midiSetup = BehaviorSubject<String?>.seeded(null);

  StreamSubscription<String>? _setupSubscription;

  LaunchpadController() {
    this._setupSubscription =
        this._midiCommand.onMidiSetupChanged?.listen((data) {
      this._midiSetup.add(data);
    });
  }

  dispose() {
    this._setupSubscription?.cancel();
  }

  Future<List<Launchpad>> listLaunchpads() async {
    final result = <Launchpad>[];
    final devices = await this._midiCommand.devices;

    if (devices == null) {
      return result;
    }

    for (final device in devices) {
      final model = parseModel(device.name);
      if (model != null) {
        result.add(Launchpad.fromDevice(
            device: device, midiCommand: this._midiCommand));
      }
    }

    return result;
  }

  Stream<String?> watchMidiSetup() => this._midiSetup;
}
