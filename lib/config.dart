import 'colors.dart' show LaunchpadColor;

enum Action {
  toggleChroma,
}

const SHORTCUTS = <({LaunchpadColor color, Action action})>[
  (color: LaunchpadColor.BLUE_1, action: Action.toggleChroma),
];
