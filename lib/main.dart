import 'dart:async' show StreamSubscription;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart'
    show
        AppBar,
        CircularProgressIndicator,
        Icons,
        ListTile,
        MaterialApp,
        MaterialPageRoute,
        Scaffold,
        ScaffoldMessenger,
        SnackBar,
        Theme;
import 'package:flutter/painting.dart' show EdgeInsets, TextAlign;
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter/widgets.dart'
    show
        AsyncSnapshot,
        BuildContext,
        Center,
        Container,
        FutureBuilder,
        Icon,
        IconData,
        ListView,
        Navigator,
        State,
        StatefulWidget,
        Text,
        Widget,
        runApp;
import 'package:flutter_launchpad/launchpad-controller.dart';
import 'package:flutter_launchpad/launchpad-models.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart'
    show MidiCommand, MidiDevice;

import 'controller.dart' show ControllerPage;
import 'launchpad.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late StreamSubscription<String?> _setupSubscription;
  final _launchpadController = LaunchpadController();

  @override
  void initState() {
    super.initState();

    _setupSubscription =
        _launchpadController.watchMidiSetup().listen((data) async {
      if (kDebugMode) {
        print("setup changed $data");
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _setupSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('FlutterMidiCommand Example'),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(24.0),
          child: const Text(
            "Tap to connnect/disconnect, long press to control.",
            textAlign: TextAlign.center,
          ),
        ),
        body: Center(
          child: FutureBuilder(
            future: _launchpadController.listLaunchpads(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                var launchpads = snapshot.data as List<Launchpad>;
                return ListView.builder(
                  itemCount: launchpads.length,
                  itemBuilder: (context, index) {
                    Launchpad launchpad = launchpads[index];

                    return ListTile(
                      title: Text(
                        launchpad.model.prettyName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      subtitle: Text(launchpad.id),
                      leading: Icon(launchpad.connected
                          ? Icons.radio_button_on
                          : Icons.radio_button_off),
                      onTap: () {
                        launchpad.connect().then((_) {
                          Navigator.of(context)
                              .push(MaterialPageRoute<void>(
                            builder: (_) => ControllerPage(launchpad),
                          ))
                              .then((value) {
                            setState(() {});
                          });
                        }).catchError((err) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "Error: ${(err as PlatformException?)?.message}")));
                        });
                      },
                    );
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }
}
