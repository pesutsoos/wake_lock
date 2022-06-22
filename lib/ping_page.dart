import 'dart:async';

import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

class PingPage extends StatefulWidget {
  const PingPage({Key? key}) : super(key: key);

  @override
  State<PingPage> createState() => _PingPageState();
}

class _PingPageState extends State<PingPage> {
  bool _isPingRunning = false;
  bool _continuousPing = false;
  late Ping _ping;
  final List<PingData> _pingResults = [];
  StreamSubscription? _pingStreamSubscription;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      toolBar: ToolBar(
        title: const Text("Ping google.com"),
        titleWidth: 200.0,
        actions: _buildActions(),
      ),
      children: [
        ContentArea(
          minWidth: 400,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              child: _buildPingResult(),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pingStreamSubscription?.cancel();
    super.dispose();
  }

  void _setPing(bool unlimitedPing) {
    if (unlimitedPing) {
      _ping = Ping("google.com");
    } else {
      _ping = Ping("google.com", count: 10);
    }
  }

  Widget _buildPingResult() {
    return _pingResults.isNotEmpty
        ? ScrollConfiguration(
            behavior:
                ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: ListView.separated(
              controller: _scrollController,
              itemBuilder: (BuildContext context, int index) {
                return MacosListTile(
                  leading: _pingResults[index].summary == null
                      ? MacosIcon(
                          CupertinoIcons.dot_square,
                          color: _pingResults[index].error == null
                              ? CupertinoColors.systemGreen
                              : CupertinoColors.systemRed,
                        )
                      : const MacosIcon(
                          CupertinoIcons.sum,
                          color: CupertinoColors.systemBlue,
                        ),
                  title: Text(
                    _pingResults[index].summary?.toString() ??
                        _pingResults[index].error?.toString() ??
                        _pingResults[index].response?.toString() ??
                        "",
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
              itemCount: _pingResults.length,
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
            ),
          )
        : const SizedBox.shrink();
  }

  List<ToolbarItem>? _buildActions() {
    List<ToolbarItem>? toolbarItems = [];
    if (_isPingRunning) {
      toolbarItems.add(_buildStopPingButton());
    } else {
      toolbarItems.add(_buildContinuousPingCheckBox());
      toolbarItems.add(_buildPingButton());
    }

    return toolbarItems;
  }

  ToolbarItem _buildContinuousPingCheckBox() {
    return CustomToolbarItem(
        inToolbarBuilder: (context) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MacosCheckbox(
                    value: _continuousPing,
                    onChanged: (value) {
                      setState(() => _continuousPing = value);
                    },
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Label(text: Text("Continuous Ping")),
                ],
              ),
            ),
        inOverflowedBuilder: (context) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MacosCheckbox(
                    value: _continuousPing,
                    onChanged: (value) {
                      setState(() => _continuousPing = value);
                    },
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Label(text: Text("Continuous Ping")),
                ],
              ),
            ));
  }

  ToolbarItem _buildPingButton() {
    return ToolBarIconButton(
      label: _continuousPing ? "Start Continuous Ping" : "Stat Ping 10x",
      icon: const MacosIcon(CupertinoIcons.play_fill),
      onPressed: () async {
        await _pingStreamSubscription?.cancel();
        _setPing(_continuousPing);
        setState(() {
          _isPingRunning = true;
          _pingResults.clear();
        });
        _pingStreamSubscription = _ping.stream.listen((PingData event) {
          setState(() {
            _pingResults.add(event);
          });
          if (_scrollController.hasClients) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          }
        }, onDone: () {
          setState(() {
            _isPingRunning = false;
          });
        });
      },
      showLabel: false,
      tooltipMessage:
          _continuousPing ? "Start Continuous Ping" : "Stat Ping 10x",
    );
  }

  ToolbarItem _buildStopPingButton() {
    return ToolBarIconButton(
      label: "Stop ping",
      icon: const MacosIcon(
        CupertinoIcons.stop_fill,
      ),
      onPressed: () {
        _ping.stop();
        Future.delayed(const Duration(milliseconds: 250)).then((value) {
          if (_scrollController.hasClients) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      },
      showLabel: false,
      tooltipMessage: "Stop ping",
    );
  }
}
