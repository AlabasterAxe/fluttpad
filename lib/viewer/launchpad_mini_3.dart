import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../colors.dart';
import '../launchpad_reader.dart';
import 'novation_logo.dart';

class SpecialPad extends StatelessWidget {
  final LaunchpadColor color;
  final Widget? child;
  final double size;
  const SpecialPad(
      {super.key, required this.color, this.child, required this.size});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Container(
          color: Colors.black,
          child: ShaderMask(
            shaderCallback: (bounds) =>
                this.color.padGradient.createShader(bounds),
            child: Center(child: child),
          )),
    );
  }
}

class LaunchpadMini3 extends StatefulWidget {
  final LaunchpadReader launchpad;
  final Function(int x, int y)? onTap;
  const LaunchpadMini3({super.key, required this.launchpad, this.onTap});

  @override
  State<LaunchpadMini3> createState() => _LaunchpadMini3State();
}

class _LaunchpadMini3State extends State<LaunchpadMini3> {
  late final StreamSubscription _eventSubscription;

  @override
  void initState() {
    super.initState();

    this._eventSubscription = this.widget.launchpad.events().listen((_) {
      setState(() {});
    });
  }

  @override
  dispose() {
    this._eventSubscription.cancel();
    super.dispose();
  }

  _specialPad(int x, int y, {required double size}) {
    if (x == 8) {
      if (y == 0) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Stop",
              style: GoogleFonts.jost(
                  textStyle: TextStyle(
                color: Colors.white,
                fontSize: size / 5,
                height: 1,
                fontWeight: FontWeight.w300,
              )),
            ),
            Text(
              "Solo",
              style: GoogleFonts.jost(
                  textStyle: TextStyle(
                color: Colors.white,
                fontSize: size / 5,
                height: 1,
                fontWeight: FontWeight.w300,
              )),
            ),
            Text(
              "Mute",
              style: GoogleFonts.jost(
                  textStyle: TextStyle(
                color: Colors.white,
                fontSize: size / 5,
                height: 1,
                fontWeight: FontWeight.w300,
              )),
            )
          ],
        );
      }
      return Text(
        ">",
        style: TextStyle(
          color: Colors.white,
          fontSize: size / 2,
        ),
      );
    }
    if (y == 8) {
      switch (x) {
        case 0:
          return Text(
            "▲",
            style: TextStyle(
              color: Colors.white,
              fontSize: size / 2,
            ),
          );
        case 1:
          return Text(
            "▼",
            style: TextStyle(
              color: Colors.white,
              fontSize: size / 2,
            ),
          );
        case 2:
          return Text(
            "◀",
            style: TextStyle(
              color: Colors.white,
              fontSize: size / 2,
            ),
          );
        case 3:
          return Text(
            "▶",
            style: TextStyle(
              color: Colors.white,
              fontSize: size / 2,
            ),
          );
        case 4:
          return Text(
            "Session",
            style: GoogleFonts.jost(
                textStyle: TextStyle(
              color: Colors.white,
              fontSize: size / 5,
              fontWeight: FontWeight.w300,
            )),
          );
        case 5:
          return Text(
            "Drums",
            style: GoogleFonts.jost(
                textStyle: TextStyle(
              color: Colors.white,
              fontSize: size / 5,
              fontWeight: FontWeight.w300,
            )),
          );
        case 6:
          return Text("Keys",
              style: GoogleFonts.jost(
                  textStyle: TextStyle(
                color: Colors.white,
                fontSize: size / 5,
                fontWeight: FontWeight.w300,
              )));
        case 7:
          return Text("User",
              style: GoogleFonts.jost(
                  textStyle: TextStyle(
                color: Colors.white,
                fontSize: size / 5,
                fontWeight: FontWeight.w300,
              )));
      }
    }
    return null;
  }

  _getShape(int x, int y, {required double size}) {
    if (x == 3 && y == 3) {
      return const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4))) +
          BeveledRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(size / 6),
            ),
          );
    } else if (x == 4 && y == 3) {
      return const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4))) +
          BeveledRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(size / 6),
            ),
          );
    } else if (x == 4 && y == 4) {
      return const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                  bottomRight: Radius.circular(4))) +
          BeveledRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(size / 6),
            ),
          );
    } else if (x == 3 && y == 4) {
      return const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(4))) +
          BeveledRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(size / 6),
            ),
          );
    }

    return RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size / 30));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final edgeSize =
          min(constraints.biggest.height, constraints.biggest.width);
      final padSize = edgeSize / 12;
      final outerPadding = edgeSize / 18;
      final gap = edgeSize / 60;
      return Container(
        color: Colors.black,
        child: Padding(
          padding: EdgeInsets.all(outerPadding),
          child: GridView.count(
              crossAxisSpacing: gap,
              mainAxisSpacing: gap,
              crossAxisCount: 9,
              children: [
                for (var y = 8; y >= 0; y--)
                  for (var x = 0; x < 9; x++)
                    GestureDetector(
                      onTap: () {
                        this.widget.onTap?.call(x, y);
                        this.setState(() {});
                      },
                      child: Container(
                        decoration: ShapeDecoration(
                          shape: _getShape(x, y, size: padSize),
                          gradient:
                              this.widget.launchpad.getColor(x, y).padGradient,
                        ),
                        child: x == 8 && y == 8
                            ? NovationLogo(
                                color: this.widget.launchpad.getColor(x, y),
                                size: padSize)
                            : x == 8 || y == 8
                                ? SpecialPad(
                                    color: this.widget.launchpad.getColor(x, y),
                                    child: _specialPad(x, y, size: padSize),
                                    size: padSize)
                                : null,
                      ),
                    ),
              ]),
        ),
      );
    });
  }
}
