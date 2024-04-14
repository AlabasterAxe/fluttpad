import 'colors.dart' show BLUE_1;

enum Action {
  toggleChroma,
}

const SHORTCUTS = <({int color, Action action})>[
  (color: BLUE_1, action: Action.toggleChroma),
];
