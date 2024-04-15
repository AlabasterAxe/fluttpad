# Flutter Launchpad

This is a little utility to control the Novation Launchpad. At the time of writing (April 2024), it is tailored to the Launchpad Mini 3 but should be generalizable to other Launchpad models.

![The LaunchpadViewer Widget](/docs/viewer.png)

## Getting Started

To get the list of attached Launchpads, you can create a singleton LaunchpadService instance. That will provide you with a list of LaunchpadControllers that you can use to read data from and push colors to.

## LaunchpadController

The LaunchpadController is a lower-level interface for controlling your Launchpad. You can use the `events()` method to listen to the events generated by your Launchpad Device. Then you can use the `setColor(int x, int y, LaunchpadColor color)` method to update the color of one of the pads (including the top row and last column).

## LaunchpadLayout

LaunchpadLayout aims to provide a slightly higher-level interface that is more reminiscent of a Flutter widget. It wraps a LaunchpadController and breaks out the various parts of the Launchpad into separate aspects that you can address by name:

```Dart

// The LaunchpadPad class sets a color and attaches an onTap callback of a pad in one fell swoop.
class LaunchpadPad {
    final LaunchpadColor color;
    final VoidCallback? onTap;
}


LaunchpadLayout(
    // The underlying LaunchpadController instance
    required this.launchpad,

    // These pads represent the "standard" pads. These pads fill the grid
    // starting from the top Left corner.
    this.pads = const <LaunchpadPad>[],

    // These are LaunchpadPad objects that control the color and functionality of the special pads.
    this.upArrow,
    this.downArrow,
    this.leftArrow,
    this.rightArrow,
    this.sessionButton,
    this.drumsButton,
    this.keysButton,
    this.userButton,

    // These LaunchpadPad objects fill the buttons running down the right side of the Launchpad
    this.sceneButtons = const <LaunchpadPad>[],
    this.stopSoloMuteButton,

    // Since it's not possible to tap the logo, this just accepts a color.
    this.logo = LaunchpadColor.OFF,
)
```

## Coordinate System

Under the hood, the Launchpad just uses an integer to index its pads. To try to make the interface a little more user-friendly, we translate the 8-bit integers into a x, y coordinate system with the origin in the lower left corner of the launchpad. This system doesn't differentiate between the "standard" pads and the "control" pads. It just treats the whole pad as a 9x9 grid of lights and buttons (with the exception of the novation logo in the top right corner which doesn't have a corresponding button).