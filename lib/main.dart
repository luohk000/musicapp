import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

final player = AudioPlayer();
Source? source = AssetSource("meow.mp3");

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: const MyHomePage(title: 'music app'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState() {
    currentSong = Song(
        title: "meow",
        artist: "cat",
        songsource: source,
        fn: changeCurrentSong);
  }
  PlayerState? playstate;
  Duration? duration;
  Duration? position;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  double currentVol = 0.5;
  Song? currentSong;

  void changeCurrentSong(Song song) {
    currentSong = song;
  }

  @override
  void initState() {
    super.initState();
    playstate = player.state;
    player.getDuration().then((value) => setState(() {
          duration = value;
        }));
    player.getCurrentPosition().then((value) => setState(() {
          position = value;
        }));
    _durationSubscription = player.onDurationChanged.listen((d) {
      setState(() => duration = d);
    });

    _positionSubscription = player.onPositionChanged.listen(
      (p) => setState(() => position = p),
    );

    _playerCompleteSubscription = player.onPlayerComplete.listen((event) {
      setState(() {
        playstate = PlayerState.stopped;
        position = Duration.zero;
      });
    });

    _playerStateChangeSubscription =
        player.onPlayerStateChanged.listen((state) {
      setState(() {
        playstate = state;
      });
    });
  }

  String getDurationTime() {
    var temp = duration?.toString().split('.').elementAt(0).split(':') ??
        ["0", "00", "00"];
    return "${temp.elementAt(1)}:${temp.elementAt(2)}";
  }

  String getPositionTime() {
    var temp = position?.toString().split('.').elementAt(0).split(':') ??
        ["0", "00", "00"];
    return "${temp.elementAt(1)}:${temp.elementAt(2)}";
  }

  Widget buildMySongPlayer(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(
          width: 2,
          color: Colors.white,
        )),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                Column(
                  children: [
                    Text(currentSong!._title!,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(currentSong!._artist!, style: TextStyle(fontSize: 12))
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    playstate == PlayerState.stopped ||
                            playstate == PlayerState.paused
                        ? player.play(source!)
                        : player.pause();
                  },
                  child: playstate == PlayerState.stopped ||
                          playstate == PlayerState.paused
                      ? const Icon(Icons.play_arrow, size: 20)
                      : const Icon(Icons.pause, size: 20),
                  style: ElevatedButton.styleFrom(shape: CircleBorder()),
                ),
              ],
            ),
            Row(
              children: [
                Text(getPositionTime()),
                const SizedBox(width: 30),
                Slider(
                    onChanged: (value) {
                      final newdur = duration;
                      if (newdur == null) return;
                      final newpos = value * newdur.inMilliseconds;
                      player.seek(Duration(milliseconds: newpos.round()));
                    },
                    value: (position != null && duration != null)
                        ? position!.inMilliseconds / duration!.inMilliseconds
                        : 0),
                const SizedBox(width: 30),
                Text(getDurationTime()),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                currentVol == 0
                    ? const Icon(Icons.volume_mute)
                    : (currentVol < 0.6
                        ? const Icon(Icons.volume_down)
                        : const Icon(Icons.volume_up)),
                Slider(
                    value: currentVol,
                    min: 0.0,
                    max: 1.0,
                    divisions: 100,
                    onChanged: (value) {
                      currentVol = value;
                      player.setVolume(currentVol);
                    })
              ],
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Song(
                title: "meow",
                artist: "cat",
                songsource: AssetSource("meow.mp3"),
                fn: changeCurrentSong),
            Song(
                title: "piano song",
                artist: "piano guy",
                songsource: AssetSource("piano.mp3"),
                fn: changeCurrentSong),
            Spacer(),
            buildMySongPlayer(context),
          ],
        ),
      ),
    );
  }
}

class Song extends StatefulWidget {
  Song(
      {super.key,
      required title,
      required artist,
      required songsource,
      required fn})
      : _title = title,
        _artist = artist,
        _songsource = songsource,
        _changesong = fn;

  final String? _title;
  final String? _artist;
  final Source? _songsource;
  final Function _changesong;

  @override
  State<Song> createState() => _SongState();
}

class _SongState extends State<Song> {
  void setMySource(Source s) {
    source = widget._songsource;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                widget._changesong(widget);
                setMySource(widget._songsource!);
                player.play(widget._songsource!);
              },
              child: Icon(
                Icons.play_arrow,
                size: 20.0,
              ),
              style: ElevatedButton.styleFrom(shape: CircleBorder()),
            ),
            Text(widget._title!),
            SizedBox(width: 100),
            Text(widget._artist!),
          ],
        ),
      ],
    );
  }
}
