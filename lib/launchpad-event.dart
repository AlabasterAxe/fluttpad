import 'package:flutter_midi_command/flutter_midi_command.dart';

enum LaunchpadEventType {
  padDown,
  padUp,
}

class LaunchpadEvent {
  final MidiPacket packet;
  LaunchpadEvent(this.packet);

  get x => packet.data[1] % 10 - 1;
  get y => packet.data[1] ~/ 10 - 1;

  get type {
    if (packet.data[2] == 0) {
      return LaunchpadEventType.padUp;
    }
    return LaunchpadEventType.padDown;
  }
}
