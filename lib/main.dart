import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MacosApp(
      title: "Wake Lock",
    );
  }
}

class WakeLockPage extends StatefulWidget {
  const WakeLockPage({Key? key}) : super(key: key);

  @override
  State<WakeLockPage> createState() => _WakeLockPageState();
}

class _WakeLockPageState extends State<WakeLockPage> {
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return const MacosWindow(
      child: MacosScaffold(
        titleBar: TitleBar(
          title: Text("abc"),
        ),
        children: [],
      ),
    );
  }
}
