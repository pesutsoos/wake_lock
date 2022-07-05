import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:wake_lock/ping_page.dart';
import 'package:wake_lock/wake_lock_page.dart';
import 'package:wake_lock/youtube_playlist.dart';

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
      home: const MainWindow(),
    );
  }
}

class MainWindow extends StatefulWidget {
  const MainWindow({Key? key}) : super(key: key);

  @override
  State<MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> {
  int _sidebarIndex = 0;
  final List<Widget> _pages = const [
    WakeLockPage(),
    PingPage(),
    YouTubePlaylist(),
  ];

  @override
  Widget build(BuildContext context) {
    return MacosWindow(
      sidebar: Sidebar(
        builder: (context, controller) {
          return SidebarItems(
            currentIndex: _sidebarIndex,
            onChanged: (i) => setState(() => _sidebarIndex = i),
            items: const [
              SidebarItem(
                leading: MacosIcon(CupertinoIcons.lock),
                label: Text("Wake lock"),
              ),
              SidebarItem(
                leading: MacosIcon(CupertinoIcons.dot_square),
                label: Text("Ping"),
              ),
              SidebarItem(
                leading: MacosIcon(CupertinoIcons.play_rectangle),
                label: Text("YouTube playlist info"),
              ),
            ],
            scrollController: controller,
          );
        },
        minWidth: 250,
      ),
      child: IndexedStack(
        index: _sidebarIndex,
        children: _pages,
      ),
    );
  }
}
