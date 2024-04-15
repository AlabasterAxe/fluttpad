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
  const LaunchpadPad({required this.color, this.onTap});
}

class LaunchpadLayout implements LaunchpadReader {
  final LaunchpadController launchpad;
  final List<LaunchpadPad> pads;
  final LaunchpadPad? upArrow;
  final LaunchpadPad? downArrow;
  final LaunchpadPad? leftArrow;
  final LaunchpadPad? rightArrow;
  final LaunchpadPad? sessionButton;
  final LaunchpadPad? drumsButton;
  final LaunchpadPad? keysButton;
  final LaunchpadPad? userButton;
  final LaunchpadPad? stopSoloMuteButton;
  final List<LaunchpadPad> sceneButtons;
  final LaunchpadColor logo;

  LaunchpadLayout({
    required this.launchpad,
    this.pads = const <LaunchpadPad>[],
    this.upArrow,
    this.downArrow,
    this.leftArrow,
    this.rightArrow,
    this.sceneButtons = const <LaunchpadPad>[],
    this.sessionButton,
    this.drumsButton,
    this.keysButton,
    this.userButton,
    this.stopSoloMuteButton,
    this.logo = LaunchpadColor.OFF,
  }) {
    this._rxSubscription = this.launchpad.events().listen(this._handleEvent);
    this._initPads();
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

  _initPads() {
    this.launchpad.clear();
    for (final (i, pad) in this.pads.indexed) {
      final (x, y) = this._padIndexToXY(i);
      if (pad.onTap != null) _handlers['$x,$y'] = pad.onTap!;
      this.launchpad.setColor(x, y, pad.color);
    }
    for (final (i, pad) in this.sceneButtons.indexed) {
      final (x, y) = this._sceneButtonToXY(i);
      if (pad.onTap != null) _handlers['$x,$y'] = pad.onTap!;
      this.launchpad.setColor(x, y, pad.color);
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
        this.launchpad.setColor(x, y, pad.color);
      }
    }

    if (this.logo != LaunchpadColor.OFF) {
      this.launchpad.setColor(8, 8, this.logo);
    }
  }
}
