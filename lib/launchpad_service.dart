import 'dart:async';

import 'package:flutter_midi_command/flutter_midi_command.dart';

import 'launchpad_models.dart' show parseModel;
import 'launchpad_controller.dart';
import 'package:rxdart/rxdart.dart';

class LaunchpadService {
  final MidiCommand _midiCommand = MidiCommand();
  final _midiSetup = BehaviorSubject<String?>.seeded(null);

  StreamSubscription<String>? _setupSubscription;

  LaunchpadService() {
    this._setupSubscription =
        this._midiCommand.onMidiSetupChanged?.listen((data) {
      this._midiSetup.add(data);
    });
  }

  dispose() {
    this._setupSubscription?.cancel();
  }

  Future<List<LaunchpadController>> listLaunchpads() async {
    final result = <LaunchpadController>[];
    final devices = await this._midiCommand.devices;

    if (devices == null) {
      return result;
    }

    for (final device in devices) {
      final model = parseModel(device.name);
      if (model != null) {
        result.add(LaunchpadController.fromDevice(
            device: device, midiCommand: this._midiCommand));
      }
    }

    return result;
  }

  Stream<String?> watchMidiSetup() => this._midiSetup;
}
