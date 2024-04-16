import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_launchpad/launchpad_models.dart';

import 'colors.dart';
import 'launchpad_event.dart';
import 'launchpad_controller.dart';
import 'launchpad_reader.dart';

class LaunchpadPad {
  final LaunchpadColor color;
  final VoidCallback? onTap;
  final LaunchpadLightMode mode;
  const LaunchpadPad(
      {required this.color, this.onTap, this.mode = LaunchpadLightMode.STATIC});
}

class LaunchpadLayout implements LaunchpadReader {
  final LaunchpadController launchpad;
  late List<LaunchpadPad> pads;
  LaunchpadPad? upArrow;
  LaunchpadPad? downArrow;
  LaunchpadPad? leftArrow;
  LaunchpadPad? rightArrow;
  LaunchpadPad? sessionButton;
  LaunchpadPad? drumsButton;
  LaunchpadPad? keysButton;
  LaunchpadPad? userButton;
  late List<LaunchpadPad> sceneButtons;
  LaunchpadPad? stopSoloMuteButton;
  LaunchpadColor logo;

  LaunchpadLayout({
    required this.launchpad,
    pads,
    this.upArrow,
    this.downArrow,
    this.leftArrow,
    this.rightArrow,
    sceneButtons,
    this.sessionButton,
    this.drumsButton,
    this.keysButton,
    this.userButton,
    this.stopSoloMuteButton,
    this.logo = LaunchpadColor.OFF,
  }) {
    this.pads = pads ?? [];
    this.sceneButtons = sceneButtons ?? [];
    this._rxSubscription = this.launchpad.events().listen(this._handleEvent);
    this._pushState();
  }

  setState({
    List<LaunchpadPad>? pads,
    LaunchpadPad? upArrow,
    LaunchpadPad? downArrow,
    LaunchpadPad? leftArrow,
    LaunchpadPad? rightArrow,
    LaunchpadPad? sessionButton,
    LaunchpadPad? drumsButton,
    LaunchpadPad? keysButton,
    LaunchpadPad? userButton,
    List<LaunchpadPad>? sceneButtons,
    LaunchpadPad? stopSoloMuteButton,
    LaunchpadColor? logo,
  }) {
    this.pads = pads ?? this.pads;
    this.upArrow = upArrow ?? this.upArrow;
    this.downArrow = downArrow ?? this.downArrow;
    this.leftArrow = leftArrow ?? this.leftArrow;
    this.rightArrow = rightArrow ?? this.rightArrow;
    this.sessionButton = sessionButton ?? this.sessionButton;
    this.drumsButton = drumsButton ?? this.drumsButton;
    this.keysButton = keysButton ?? this.keysButton;
    this.userButton = userButton ?? this.userButton;
    this.sceneButtons = sceneButtons ?? this.sceneButtons;
    this.stopSoloMuteButton = stopSoloMuteButton ?? this.stopSoloMuteButton;
    this.logo = logo ?? this.logo;
    this._pushState();
  }

  @override
  Stream<LaunchpadEvent> events() {
    return this.launchpad.events();
  }

  @override
  LaunchpadColor getColor(int x, int y) {
    return this.launchpad.getColor(x, y);
  }

  dispose() {
    this._rxSubscription.cancel();
  }

  @override
  LaunchpadModel get model => this.launchpad.model;

  late final StreamSubscription _rxSubscription;
  final _handlers = <String, VoidCallback>{};

  _handleXYClick(int x, int y) => _handlers['$x,$y']?.call();

  _handleEvent(LaunchpadEvent event) {
    if (kDebugMode) {
      print('received packet ${event.x}, ${event.y}, ${event.type}');
    }

    if (event.type == LaunchpadEventType.padUp) {
      return;
    }

    this._handleXYClick(event.x, event.y);
  }

  _padIndexToXY(int index) {
    final x = index % 8;
    final y = 7 - index ~/ 8;
    return (x, y);
  }

  _sceneButtonToXY(int index) {
    return (8, 7 - index);
  }

  _pushState() {
    this.launchpad.clear();
    for (final (i, pad) in this.pads.indexed) {
      final (x, y) = this._padIndexToXY(i);
      if (pad.onTap != null) _handlers['$x,$y'] = pad.onTap!;
      this.launchpad.setColor(x, y, pad.color, pad.mode);
    }
    for (final (i, pad) in this.sceneButtons.indexed) {
      final (x, y) = this._sceneButtonToXY(i);
      if (pad.onTap != null) _handlers['$x,$y'] = pad.onTap!;
      this.launchpad.setColor(x, y, pad.color, pad.mode);
    }

    for (final (pad, (x, y)) in [
      (this.upArrow, (0, 8)),
      (this.downArrow, (1, 8)),
      (this.leftArrow, (2, 8)),
      (this.rightArrow, (3, 8)),
      (this.sessionButton, (4, 8)),
      (this.drumsButton, (5, 8)),
      (this.keysButton, (6, 8)),
      (this.userButton, (7, 8)),
      (this.stopSoloMuteButton, (8, 0)),
    ]) {
      if (pad != null) {
        if (pad.onTap != null) {
          this._handlers['$x,$y'] = pad.onTap!;
        }
        this.launchpad.setColor(x, y, pad.color, pad.mode);
      }
    }

    if (this.logo != LaunchpadColor.OFF) {
      this.launchpad.setColor(8, 8, this.logo);
    }
  }
}
