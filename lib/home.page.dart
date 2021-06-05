import 'dart:async';

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'models/music.dart';
import 'models/actionMusic.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Music> myPlayList = [
    new Music('N’GA PÂTÉ', 'FALAYE-P', 'assets/images/ngapate.jpg',
        'https://www.kowbey.com/telecharger/s_NK8s_HLLqaxZUba3Mewz_43x9asP0mLAtenef3GKs,'),
    new Music('LALABI BERTHE TOURABOU', 'ADJI ONE CENTHIAGO', 'assets/images/lalabi.jpg',
        'https://www.bamada-city.com/wp-content/uploads/2020/07/6-ADJI-ONE-CENTHIAGO-LALABI-BERTHE-TOURABOU-MASSA-Prod-by-LAGARE-PROD.mp3')
  ];

  Music currentMusic;
  Duration position = new Duration(seconds: 0);
  Duration duree = new Duration(seconds: 0);
  StreamSubscription positionSub;
  StreamSubscription stateSub;
  AudioPlayer audioPlayer;
  PlayerState status = PlayerState.stopped;
  int index = 0;

  @override
  void initState() {
    super.initState();
    currentMusic = myPlayList[index];
    configureAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 15.0,
      ),
      body: Center(
        child: Container(
          color: Colors.grey[900],
          width: width,
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                height: 20.0,
              ),
              Card(
                elevation: 10.0,
                child: Container(
                  width: width / 1.5,
                  height: height / 2.8,
                  child: Image.asset(
                    currentMusic.imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              textWidget(currentMusic.title, 2.0),
              SizedBox(
                height: 20.0,
              ),
              textWidget(currentMusic.artist, 2.0),
              Container(
                height: height / 6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _iconButton(
                        Icons.fast_rewind_sharp, 30.0, ActionMusic.rewind),
                    _iconButton(
                        (status == PlayerState.playing)
                            ? Icons.pause
                            : Icons.play_arrow,
                        45.0,
                        (status == PlayerState.playing)
                            ? ActionMusic.pause
                            : ActionMusic.play),
                    _iconButton(
                        Icons.fast_forward_sharp, 30.0, ActionMusic.forward),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  textWidget(fromDuration(position), 2.0),
                  textWidget(fromDuration(duree), 2.0),
                ],
              ),
              Slider(
                value: position.inSeconds.toDouble(),
                min: 0,
                max: duree.inSeconds.toDouble(),
                inactiveColor: Colors.white,
                activeColor: Colors.red,
                onChanged: (double d) {
                  setState(() {
                    audioPlayer.seek(d);
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Text textWidget(String data, double scale) {
    return Text(data,
        style: TextStyle(
            fontStyle: FontStyle.italic, fontSize: 10.0, color: Colors.white),
        textScaleFactor: scale);
  }

  IconButton _iconButton(IconData icon, double size, ActionMusic action) {
    return IconButton(
      iconSize: size,
      color: Colors.white,
      icon: Icon(icon),
      onPressed: () {
        switch (action) {
          case ActionMusic.play:
            play();
            break;
          case ActionMusic.pause:
            pause();
            break;
          case ActionMusic.rewind:
            rewind();
            break;
          case ActionMusic.forward:
            forward();
            break;
        }
      },
    );
  }

  void configureAudioPlayer() {
    audioPlayer = new AudioPlayer();
    positionSub = audioPlayer.onAudioPositionChanged
        .listen((event) => setState(() => position = event));

    stateSub = audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == AudioPlayerState.PLAYING) {
        setState(() {
          duree = audioPlayer.duration;
        });
      } else if (state == AudioPlayerState.STOPPED) {
        setState(() {
          status = PlayerState.stopped;
        });
      }
    }, onError: (message) {
      print('erreur: $message');
      setState(() {
        status = PlayerState.stopped;
        duree = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });
  }

  Future play() async {
    await audioPlayer.play(currentMusic.songPath);
    setState(() {
      status = PlayerState.playing;
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() {
      status = PlayerState.paused;
    });
  }

  void forward() {
    if (index == myPlayList.length - 1) {
      index = 0;
    } else {
      index++;
    }
    currentMusic = myPlayList[index];
    audioPlayer.stop();
    configureAudioPlayer();
    play();
  }

  void rewind() {
    if (position > Duration(seconds: 3)) {
      audioPlayer.seek(0.0);
    } else {
      if (index == 0) {
        index = myPlayList.length - 1;
      } else {
        index--;
      }
      currentMusic = myPlayList[index];
      audioPlayer.stop();
      configureAudioPlayer();
      play();
    }
  }

  String fromDuration(Duration time) {
    return time.toString().split('.').first;
  }
}
