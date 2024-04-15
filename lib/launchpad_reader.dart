import 'colors.dart';
import 'launchpad_event.dart';
import 'launchpad_models.dart';

abstract class LaunchpadReader {
  LaunchpadColor getColor(int x, int y);
  LaunchpadModel get model;
  Stream<LaunchpadEvent> events();
}
