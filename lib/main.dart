import 'dart:async' show StreamSubscription;

import 'package:flutter/foundation.dart' show Key, kDebugMode;
import 'package:flutter/material.dart'
    show
        AlertDialog,
        AppBar,
        CircularProgressIndicator,
        IconButton,
        Icons,
        ListTile,
        MaterialApp,
        MaterialPageRoute,
        Scaffold,
        ScaffoldMessenger,
        SnackBar,
        Switch,
        TextButton,
        Theme,
        showDialog;
import 'package:flutter/painting.dart' show EdgeInsets, TextAlign;
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter/widgets.dart'
    show
        AsyncSnapshot,
        BuildContext,
        Builder,
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
import 'package:flutter_midi_command/flutter_midi_command.dart'
    show MidiCommand, MidiDevice;

import 'controller.dart' show ControllerPage;

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  StreamSubscription<String>? _setupSubscription;
  final MidiCommand _midiCommand = MidiCommand();

  bool _virtualDeviceActivated = false;
  bool _iOSNetworkSessionEnabled = false;

  bool _didAskForBluetoothPermissions = false;

  @override
  void initState() {
    super.initState();

    _setupSubscription = _midiCommand.onMidiSetupChanged?.listen((data) async {
      if (kDebugMode) {
        print("setup changed $data");
      }
      setState(() {});
    });

    _updateNetworkSessionState();
  }

  @override
  void dispose() {
    _setupSubscription?.cancel();
    super.dispose();
  }

  _updateNetworkSessionState() async {
    var nse = await _midiCommand.isNetworkSessionEnabled;
    if (nse != null) {
      setState(() {
        _iOSNetworkSessionEnabled = nse;
      });
    }
  }

  IconData _deviceIconForType(String type) {
    switch (type) {
      case "native":
        return Icons.devices;
      case "network":
        return Icons.language;
      case "BLE":
        return Icons.bluetooth;
      default:
        return Icons.device_unknown;
    }
  }

  Future<void> _informUserAboutBluetoothPermissions(
      BuildContext context) async {
    if (_didAskForBluetoothPermissions) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
              'Please Grant Bluetooth Permissions to discover BLE MIDI Devices.'),
          content: const Text(
              'In the next dialog we might ask you for bluetooth permissions.\n'
              'Please grant permissions to make bluetooth MIDI possible.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok. I got it!'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    _didAskForBluetoothPermissions = true;

    return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('FlutterMidiCommand Example'),
          actions: <Widget>[
            Switch(
                value: _iOSNetworkSessionEnabled,
                onChanged: (newValue) {
                  _midiCommand.setNetworkSessionEnabled(newValue);
                  setState(() {
                    _iOSNetworkSessionEnabled = newValue;
                  });
                }),
            Switch(
                value: _virtualDeviceActivated,
                onChanged: (newValue) {
                  setState(() {
                    _virtualDeviceActivated = newValue;
                  });
                  if (newValue) {
                    _midiCommand.addVirtualDevice(name: "Flutter MIDI Command");
                  } else {
                    _midiCommand.removeVirtualDevice(
                        name: "Flutter MIDI Command");
                  }
                }),
            Builder(builder: (context) {
              return IconButton(
                  onPressed: () async {
                    // Ask for bluetooth permissions
                    await _informUserAboutBluetoothPermissions(context);

                    // Start bluetooth
                    if (kDebugMode) {
                      print("start ble central");
                    }
                    await _midiCommand
                        .startBluetoothCentral()
                        .catchError((err) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(err),
                      ));
                    });

                    if (kDebugMode) {
                      print("wait for init");
                    }
                    await _midiCommand
                        .waitUntilBluetoothIsInitialized()
                        .timeout(const Duration(seconds: 5), onTimeout: () {
                      if (kDebugMode) {
                        print("Failed to initialize Bluetooth");
                      }
                    });

                    if (kDebugMode) {
                      print("done");
                    }
                    // If not show a message telling users what to do
                    setState(() {});
                  },
                  icon: const Icon(Icons.refresh));
            }),
          ],
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
            future: _midiCommand.devices,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                var devices = snapshot.data as List<MidiDevice>;
                return ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    MidiDevice device = devices[index];

                    return ListTile(
                      title: Text(
                        device.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      subtitle: Text(
                          "ins:${device.inputPorts.length} outs:${device.outputPorts.length}, ${device.id}, ${device.type}"),
                      leading: Icon(device.connected
                          ? Icons.radio_button_on
                          : Icons.radio_button_off),
                      trailing: Icon(_deviceIconForType(device.type)),
                      onLongPress: () {
                        _midiCommand.stopScanningForBluetoothDevices();
                        Navigator.of(context)
                            .push(MaterialPageRoute<void>(
                          builder: (_) => ControllerPage(device),
                        ))
                            .then((value) {
                          setState(() {});
                        });
                      },
                      onTap: () {
                        if (device.connected) {
                          if (kDebugMode) {
                            print("disconnect");
                          }
                          _midiCommand.disconnectDevice(device);
                        } else {
                          if (kDebugMode) {
                            print("connect");
                          }
                          _midiCommand.connectToDevice(device).then((_) {
                            if (kDebugMode) {
                              print("device connected async");
                            }
                          }).catchError((err) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    "Error: ${(err as PlatformException?)?.message}")));
                          });
                        }
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
