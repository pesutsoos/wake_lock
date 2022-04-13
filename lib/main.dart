import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:wakelock/wakelock.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MacosApp(
      title: "Wake Lock",
      theme: MacosThemeData.light(),
      darkTheme: MacosThemeData.dark(),
      home: const WakeLockPage(),
    );
  }
}

class WakeLockPage extends StatefulWidget {
  const WakeLockPage({Key? key}) : super(key: key);

  @override
  State<WakeLockPage> createState() => _WakeLockPageState();
}

class _WakeLockPageState extends State<WakeLockPage> {
  bool switchState = false;

  @override
  Widget build(BuildContext context) {
    return MacosWindow(
      child: RawKeyboardListener(
        autofocus: true,
        focusNode: FocusNode(),
        onKey: (event) {
          if (event is RawKeyDownEvent) {
            if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
              setState(() {
                switchState = !switchState;
              });
            }
          }
        },
        child: MacosScaffold(
          children: [
            ContentArea(
              builder: (context, scrollController) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          "Wake Lock is ${switchState ? 'enabled' : 'disabled'}."),
                      const SizedBox(height: 10),
                      MacosSwitch(
                        value: switchState,
                        onChanged: (value) {
                          setState(() => switchState = value);
                          Wakelock.toggle(enable: switchState);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
