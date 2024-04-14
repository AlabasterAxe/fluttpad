enum LaunchpadColor {
  OFF(0),
  DARK_GREY(1),
  LIGHT_GREY(2),
  WHITE(3),
  PINK(4),
  RED_1(5),
  RED_2(6),
  RED_3(7),
  PALE_ORANGE(8),
  ORANGE_1(9),
  ORANGE_2(10),
  ORANGE_3(11),
  BROWN(11),
  PALE_YELLOW(12),
  YELLOW_1(13),
  YELLOW_2(14),
  YELLOW_3(15),
  PALE_GREEN(20),
  GREEN_1(21),
  GREEN_2(22),
  GREEN_3(23),
  PALE_TEAL(32),
  TEAL_1(33),
  TEAL_2(34),
  TEAL_3(35),
  PALE_BLUE(40),
  BLUE_1(41),
  BLUE_2(42),
  BLUE_3(43),
  PALE_INDIGO(44),
  INDIGO_1(45),
  INDIGO_2(46),
  INDIGO_3(47),
  PALE_PURPLE(48),
  PURPLE_1(49),
  PURPLE_2(50),
  PURPLE_3(51);

  const LaunchpadColor(this.value);
  final int value;
}

enum LaunchpadLightMode {
  STATIC(144),
  FLASH(145),
  PULSE(146);

  const LaunchpadLightMode(this.value);
  final int value;
}
