import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:wakelock/wakelock.dart';

const String lockedIconPath = "asset/icons/baseline_lock_white_24dp.png";
const String unlockedIconPath =
    "asset/icons/baseline_no_encryption_white_24dp.png";
const String enableKey = "enable";
const String disableKey = "disable";

class WakeLockPage extends StatefulWidget {
  const WakeLockPage({Key? key}) : super(key: key);

  @override
  State<WakeLockPage> createState() => _WakeLockPageState();
}

class _WakeLockPageState extends State<WakeLockPage> with TrayListener {
  bool _switchState = false;

  @override
  void initState() {
    super.initState();
    trayManager.addListener(this);
    initTrayManager();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKey: (event) {
        if (event is RawKeyDownEvent) {
          if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
            toggleWakeLock(!_switchState);
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
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Image.asset(
                          _switchState ? lockedIconPath : unlockedIconPath,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Wake Lock is ${_switchState ? 'enabled' : 'disabled'}.",
                          style: CupertinoTheme.of(context)
                              .textTheme
                              .navTitleTextStyle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    MacosSwitch(
                      value: _switchState,
                      onChanged: (value) {
                        toggleWakeLock(value);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    super.dispose();
  }

  @override
  void onTrayIconMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseDown() {
    toggleWakeLock(!_switchState);
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == enableKey) {
      toggleWakeLock(true);
    } else if (menuItem.key == disableKey) {
      toggleWakeLock(false);
    }
  }

  Future<void> initTrayManager() async {
    await toggleWakeLock(true);
  }

  Future<void> toggleWakeLock(bool enabled) async {
    setState(() => _switchState = enabled);
    await Wakelock.toggle(enable: _switchState);
    if (_switchState) {
      await trayManager.setIcon(lockedIconPath);
      await trayManager.setContextMenu(_buildMenuItems(_switchState));
    } else {
      await trayManager.setIcon(unlockedIconPath);
      await trayManager.setContextMenu(_buildMenuItems(_switchState));
    }
  }

  List<MenuItem> _buildMenuItems(bool wakeLockEnabled) {
    return wakeLockEnabled
        ? [
            MenuItem(
              title: "Disable wake lock",
              key: disableKey,
            ),
          ]
        : [
            MenuItem(
              title: "Enable wake lock",
              key: enableKey,
            ),
          ];
  }
}
