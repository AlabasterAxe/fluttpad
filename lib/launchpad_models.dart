// These codes are used to identify the Launchpad model. If the MIDI name
// contains one of these strings, the Launchpad model is identified.

const LAUNCHPAD_MINI_MK3 = "LPMiniMK3 MIDI";

LaunchpadModel? parseModel(String midiDeviceName) {
  if (midiDeviceName.contains(LAUNCHPAD_MINI_MK3)) {
    return LaunchpadModel.MINI_MK3;
  }
  return null;
}

enum LaunchpadModel {
  MINI_MK3,
}

// name extension to the LaunchpadModel enum
extension LaunchpadModelExtension on LaunchpadModel {
  String get prettyName {
    switch (this) {
      case LaunchpadModel.MINI_MK3:
        return "Launchpad Mini MK3";
      default:
        return "Unknown";
    }
  }
}
