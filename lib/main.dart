import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:wake_lock/wake_lock_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
