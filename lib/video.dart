import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter_volume_slider/flutter_volume_slider.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gather Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.deepPurple,
      ),
      home: VideoPage(title: 'Gather for prayer'),
    );
  }
}

class VideoPage extends StatefulWidget {
  VideoPage({Key key, this.title}) : super(key: key);
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  int _counter = 0;
  static String myVideoId = 'ED7-a2gquSQ';

  // Initiate the Youtube player controller
  YoutubePlayerController _controller = YoutubePlayerController(
    initialVideoId: myVideoId,
    flags: YoutubePlayerFlags(
      autoPlay: true,
      mute: false,
    ),
  );

  @override
  Widget build(BuildContext context) {
    Random random = new Random();
    int numAttendees = random.nextInt(50) + 5;
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
          title: Row(
        children: [
          Image.asset(
            'assets/nyu-ic.png',
            fit: BoxFit.scaleDown,
            height: 32,
          ),
          Container(
              padding: const EdgeInsets.all(8.0),
              child: Text('Gather - NYU Islamic Center'))
        ],
      )),
      body: Container(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: ListView(children: <Widget>[
            YoutubePlayer(
              controller: _controller,
              liveUIColor: Colors.amber,
            ),
            FlutterVolumeSlider(
              display: Display.HORIZONTAL,
              sliderActiveColor: Colors.blue,
              sliderInActiveColor: Colors.grey,
            ),
            Container(
                height: 60.0,
                width: 60.0,
                child: Text('Today\'s Topic: Neighbors',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
            Container(
              height: 40.0,
              width: 40.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/group.png'),
                ),
                shape: BoxShape.circle,
              ),
            ),
            Container(
                height: 40.0,
                width: 60.0,
                child: Text('Attendees in Meeting',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18))),
            Container(
                height: 60.0,
                width: 60.0,
                child: Text(numAttendees.toString(),
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
            ElevatedButton(
              onPressed: () {},
              child: Text('Exit Meeting'),
            ),
          ]),
        ),
      ),
    );
  }
}
