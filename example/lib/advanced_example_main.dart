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
        ListView,
        Navigator,
        State,
        StatefulWidget,
        Text,
        Widget,
        runApp;
import 'package:flutter_launchpad/launchpad_controller.dart';
import 'package:flutter_launchpad/launchpad_models.dart';
import 'package:flutter_launchpad/launchpad_service.dart';

import 'app_chooser.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late StreamSubscription<String?> _setupSubscription;
  final _launchpadService = LaunchpadService();

  @override
  void initState() {
    super.initState();

    _setupSubscription =
        _launchpadService.watchMidiSetup().listen((data) async {
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
            future: _launchpadService.listLaunchpads(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                var launchpads = snapshot.data as List<LaunchpadController>;
                return ListView.builder(
                  itemCount: launchpads.length,
                  itemBuilder: (context, index) {
                    LaunchpadController launchpad = launchpads[index];

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
                            builder: (_) => AppChooser(launchpad: launchpad),
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
