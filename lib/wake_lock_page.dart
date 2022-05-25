import 'dart:ui';

import 'package:flutter/cupertino.dart' hide MenuItem;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:macos_ui/macos_ui.dart';

import 'package:tray_manager/tray_manager.dart';
import 'package:wakelock/wakelock.dart';

const String enableKey = "enable";
const String disableKey = "disable";

class WakeLockPage extends StatefulWidget {
  const WakeLockPage({Key? key}) : super(key: key);

  @override
  State<WakeLockPage> createState() => _WakeLockPageState();
}

class _WakeLockPageState extends State<WakeLockPage> with TrayListener {
  bool _switchState = false;
  CountdownTimerController? _controller;

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
              return Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Image.asset(
                              _switchState
                                  ? _getLockIconPath()
                                  : _getUnlockIconPath(),
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
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: _controller != null
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 10,
                              children: [
                                MacosTooltip(
                                  message: "Cancel timer",
                                  child: MacosIconButton(
                                    semanticLabel: "Cancel timer",
                                    onPressed: _cancelController,
                                    icon: const Icon(CupertinoIcons.timer),
                                  ),
                                ),
                                CountdownTimer(
                                  controller: _controller,
                                  textStyle: CupertinoTheme.of(context)
                                      .textTheme
                                      .textStyle
                                      .copyWith(
                                    fontFeatures: [
                                      const FontFeature.tabularFigures(),
                                    ],
                                    // fontSize: 50,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
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
    _controller?.dispose();
    Wakelock.disable();
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
    await trayManager.setToolTip("Wake Lock");
  }

  Future<void> toggleWakeLock(bool enabled) async {
    setState(() => _switchState = enabled);
    await Wakelock.toggle(enable: _switchState);
    if (_switchState) {
      await trayManager.setIcon(_getLockIconPath());
      await trayManager.setContextMenu(_buildMenuItems(_switchState));
      _setController();
    } else {
      await trayManager.setIcon(_getUnlockIconPath());
      await trayManager.setContextMenu(_buildMenuItems(_switchState));
      _cancelController();
    }
  }

  Menu _buildMenuItems(bool wakeLockEnabled) {
    return wakeLockEnabled
        ? Menu(items: [
            MenuItem(
              label: "Disable wake lock",
              key: disableKey,
            ),
          ])
        : Menu(items: [
            MenuItem(
              label: "Enable wake lock",
              key: enableKey,
            ),
          ]);
  }

  String _getLockIconPath() {
    return SchedulerBinding.instance.window.platformBrightness ==
            Brightness.light
        ? "asset/icons/baseline_lock_black_24dp.png"
        : "asset/icons/baseline_lock_white_24dp.png";
  }

  String _getUnlockIconPath() {
    return SchedulerBinding.instance.window.platformBrightness ==
            Brightness.light
        ? "asset/icons/baseline_no_encryption_black_24dp.png"
        : "asset/icons/baseline_no_encryption_white_24dp.png";
  }

  void _setController() {
    DateTime now = DateTime.now();
    int endTime = DateTime(now.year, now.month, now.day, 16, 0, 0, 0, 0)
        .millisecondsSinceEpoch;
    if (now.hour > 16) {
      endTime += 86400000;
    }

    _controller?.dispose();
    setState(() {
      _controller = CountdownTimerController(endTime: endTime, onEnd: _onEnd);
    });
  }

  void _cancelController() {
    _controller?.dispose();
    setState(() {
      _controller = null;
    });
  }

  void _onEnd() {
    toggleWakeLock(false);
  }
}
