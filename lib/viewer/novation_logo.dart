import 'package:flutter/material.dart';

import '../colors.dart';

class NovationLogo extends StatelessWidget {
  final LaunchpadColor color;
  final double size;
  const NovationLogo({super.key, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => color.padGradient.createShader(bounds),
      child: Container(
        padding: EdgeInsets.all(this.size / 6),
        color: Colors.black,
        child: Image.asset("assets/novation.png", package: "flutter_launchpad"),
      ),
    );
  }
}
