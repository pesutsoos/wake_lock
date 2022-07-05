import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YouTubePlaylist extends StatefulWidget {
  const YouTubePlaylist({Key? key}) : super(key: key);

  @override
  State<YouTubePlaylist> createState() => _YouTubePlaylistState();
}

class _YouTubePlaylistState extends State<YouTubePlaylist> {
  String _youtubePlaylist = "";
  bool _isFetchRunning = false;
  final List<String> _fetchResults = [];

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      toolBar: ToolBar(
        title: const Text("YouTube playlist info"),
        titleWidth: 200.0,
        actions: _buildActions(),
      ),
      children: [
        ContentArea(
          minWidth: 400,
          builder: (BuildContext context, ScrollController scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              child: _buildFetchResult(),
            );
          },
        ),
      ],
    );
  }

  List<ToolbarItem>? _buildActions() {
    List<ToolbarItem>? toolbarItems = [];
    toolbarItems.add(_buildTextField());
    if (_isFetchRunning) {
      toolbarItems.add(_buildFetchInProgress());
    } else {
      toolbarItems.add(_buildFetchYouTubeInfoButton());
    }

    return toolbarItems;
  }

  Widget _buildFetchResult() {
    return _fetchResults.isNotEmpty
        ? ScrollConfiguration(
            behavior:
                ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: ListView.separated(
              itemBuilder: (BuildContext context, int index) {
                return Text(_fetchResults[index]);
              },
              itemCount: _fetchResults.length,
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
            ),
          )
        : const SizedBox.shrink();
  }

  ToolbarItem _buildTextField() {
    return CustomToolbarItem(inToolbarBuilder: (BuildContext context) {
      return SizedBox(
        width: 200,
        child: MacosTextField(
          placeholder: "YouTube playlist url",
          onChanged: (text) {
            setState(() {
              _youtubePlaylist = text;
            });
          },
          clearButtonMode: OverlayVisibilityMode.editing,
          onSubmitted: (text) {
            setState(() {
              _youtubePlaylist = text;
            });
            _fetchYouTubePlaylist();
          },
        ),
      );
    });
  }

  ToolbarItem _buildFetchYouTubeInfoButton() {
    return ToolBarIconButton(
      label: "Fetch",
      icon: const MacosIcon(cupertino.CupertinoIcons.play_fill),
      onPressed: _fetchYouTubePlaylist,
      showLabel: false,
      tooltipMessage: "Fetch",
    );
  }

  ToolbarItem _buildFetchInProgress() {
    return CustomToolbarItem(inToolbarBuilder: (BuildContext context) {
      return const Padding(
        padding: EdgeInsets.only(
          right: 12,
          left: 12,
        ),
        child: ProgressCircle(),
      );
    });
  }

  String getDurationHms(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours == 0) {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void _fetchYouTubePlaylist() async {
    setState(() {
      _isFetchRunning = true;
      _fetchResults.clear();
    });
    try {
      var yt = YoutubeExplode();
      var playlist = await yt.playlists.get(_youtubePlaylist);
      var playlistLength = Duration.zero;
      await for (var video in yt.playlists.getVideos(playlist.id)) {
        playlistLength += video.duration ?? Duration.zero;
      }

      setState(() {
        _isFetchRunning = false;
        _fetchResults.add(playlist.title);
        _fetchResults.add(playlist.author);
        _fetchResults.add("No of videos: ${playlist.videoCount ?? 0}");
        _fetchResults
            .add("Playlist length = ${getDurationHms(playlistLength)}");
        int duration125 = playlistLength.inMilliseconds.toDouble() ~/ 1.25;
        int duration150 = playlistLength.inMilliseconds.toDouble() ~/ 1.50;
        int duration175 = playlistLength.inMilliseconds.toDouble() ~/ 1.75;
        int duration200 = playlistLength.inMilliseconds.toDouble() ~/ 2.0;

        String d125 = getDurationHms(Duration(milliseconds: duration125));
        String d150 = getDurationHms(Duration(milliseconds: duration150));
        String d175 = getDurationHms(Duration(milliseconds: duration175));
        String d200 = getDurationHms(Duration(milliseconds: duration200));

        _fetchResults.add("At 1.25x  $d125");
        _fetchResults.add("At 1.50x  $d150");
        _fetchResults.add("At 1.75x  $d175");
        _fetchResults.add("At 2.00x  $d200");

        if (playlist.description.isNotEmpty) {
          _fetchResults.add("--------------------------------");
          _fetchResults.add(playlist.description);
        }
      });
    } catch (e) {
      setState(() {
        _isFetchRunning = false;
        _fetchResults.add(e.toString());
      });
    }
  }
}
