import 'dart:math';
import 'dart:ui';

import 'package:flutter/painting.dart';

enum LaunchpadColor {
  OFF(0, Color(0xFF000000)),
  DARK_GREY(1, Color(0xFF333333)),
  LIGHT_GREY(2, Color(0xFFCCCCCC)),
  WHITE(3, Color(0xFFFFFFFF)),
  PINK(4, Color(0xFFFF69B4)),
  RED_1(5, Color(0xFFFF0000)),
  RED_2(6, Color(0xFFCC0000)),
  RED_3(7, Color(0xFF990000)),
  PALE_ORANGE(8, Color(0xFFFFCC99)),
  ORANGE_1(9, Color(0xFFFF6600)),
  ORANGE_2(10, Color(0xFFFF3300)),
  ORANGE_3(11, Color(0xFFFF0000)),
  BROWN(11, Color(0xFF663300)),
  PALE_YELLOW(12, Color(0xFFFFFF99)),
  YELLOW_1(13, Color(0xFFFFFF00)),
  YELLOW_2(14, Color(0xFFFFCC00)),
  YELLOW_3(15, Color(0xFFFF9900)),
  PALE_GREEN(20, Color(0xFF99FF99)),
  GREEN_1(21, Color(0xFF00FF00)),
  GREEN_2(22, Color(0xFF00CC00)),
  GREEN_3(23, Color(0xFF009900)),
  PALE_TEAL(32, Color(0xFF99FFFF)),
  TEAL_1(33, Color(0xFF00FFFF)),
  TEAL_2(34, Color(0xFF00CCCC)),
  TEAL_3(35, Color(0xFF009999)),
  PALE_BLUE(40, Color(0xFF99CCFF)),
  BLUE_1(41, Color(0xFF0000FF)),
  BLUE_2(42, Color(0xFF0000CC)),
  BLUE_3(43, Color(0xFF000099)),
  PALE_INDIGO(44, Color(0xFFCC99FF)),
  INDIGO_1(45, Color(0xFF6600FF)),
  INDIGO_2(46, Color(0xFF3300CC)),
  INDIGO_3(47, Color(0xFF330099)),
  PALE_PURPLE(48, Color(0xFFFF99FF)),
  PURPLE_1(49, Color(0xFFFF00FF)),
  PURPLE_2(50, Color(0xFFCC00CC)),
  PURPLE_3(51, Color(0xFF990099));

  const LaunchpadColor(this.value, this.color);
  final int value;
  final Color color;

  static fromValue(int value) {
    for (var color in LaunchpadColor.values) {
      if (color.value == value) {
        return color;
      }
    }
  }

  get padGradient => RadialGradient(
        colors: [
          this == LaunchpadColor.OFF ? UNLIT_PAD : this.color,
          this == LaunchpadColor.OFF
              ? UNLIT_PAD
              : Color.alphaBlend(
                  this.color.withOpacity(.3),
                  UNLIT_PAD,
                ),
        ],
        stops: const [0.0, 1.0],
      );
}

enum LaunchpadLightMode {
  STATIC(144),
  FLASH(145),
  PULSE(146);

  const LaunchpadLightMode(this.value);
  final int value;
}

const UNLIT_PAD = Color.fromARGB(255, 127, 127, 127);
