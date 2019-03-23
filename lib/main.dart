import 'package:flutter/material.dart';
import 'package:flutter_chromecast_example/service_discovery.dart';
import 'package:dart_chromecast/casting/cast.dart';
import 'package:flutter_chromecast_example/device_picker.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Casting Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Cast Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ServiceDiscovery _serviceDiscovery;
  CastSender _castSender;

  bool connected = false;

  List _videoItems = [
    CastMedia(
      title: 'Chrome Cast Video 1',
      contentId:
          'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      images: [
        'https://static1.squarespace.com/static/5647f7e9e4b0f54883c66275/5647f9afe4b0caa2cf189d56/56489d67e4b0734a6c410a64/1447599477357/?format=1500w'
      ],
    ),
    CastMedia(
        title: 'Chrome Cast Video 2',
        contentId:
            'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        images: ['https://i.ytimg.com/vi/dCfOxU1uFK8/maxresdefault.jpg'])
  ];

  void initState() {
    super.initState();

    _serviceDiscovery = ServiceDiscovery();
    _serviceDiscovery.startDiscovery();
  }

  void _connectToDevice(CastDevice device) async {
    _castSender = CastSender(device);
    connected = await _castSender.connect();
    if (!connected) {
      // show error message...
      return;
    }

    setState(() {});

    //if you want to connect to your custom app, send AppID as a parameter i.e. _castSender.launch("appId")
    _castSender.launch();
  }

  Widget _buildVideoListItem(BuildContext context, int index) {
    CastMedia castMedia = _videoItems[index];
    return GestureDetector(
      onTap: () => null != _castSender ? _castSender.load(castMedia) : null,
      child: Card(
        child: Column(
          children: <Widget>[
            Image.network(castMedia.images.first),
            Text(castMedia.title),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Builder(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
          actions: <Widget>[
            // action button
            IconButton(
              icon: Icon(
                connected ? Icons.cast_connected : Icons.cast,
                color: Colors.white,
              ),
              onPressed: () {
                /*Navigator.of(context)
                    .push(new MaterialPageRoute(
                      builder: (BuildContext context) => DevicePicker(serviceDiscovery: _serviceDiscovery, onDevicePicked: _connectToDevice),
                      fullscreenDialog: true,
                ));*/

                showDialog(
                    context: context,
                    builder: (_) => DevicePicker(
                        serviceDiscovery: _serviceDiscovery,
                        onDevicePicked: _connectToDevice));
              },
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Container(
              height: 500.0,
              child: ListView.builder(
                itemBuilder: _buildVideoListItem,
                itemCount: _videoItems.length,
              ),
            ),
            Row(
              children: <Widget>[
                FlatButton(
                  child: Icon(Icons.fast_rewind),
                  onPressed: () {
                    //rewind 10 seconds from current video position
                    _castSender.seek(
                        _castSender.castSession.castMediaStatus.position -
                            10.0);
                  },
                ),
                FlatButton(
                  child: Icon(Icons.play_arrow),
                  onPressed: () {
                    _castSender.togglePause();
                  },
                ),
                FlatButton(
                  child: Icon(Icons.stop),
                  onPressed: () {
                    _castSender.stop();
                  },
                ),
                FlatButton(
                  child: Icon(Icons.fast_forward),
                  onPressed: () {
                    //fast forward 10 seconds from current video position
                    _castSender.seek(
                        _castSender.castSession.castMediaStatus.position +
                            10.0);
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Material(
                borderRadius: BorderRadius.circular(5.0),
                shadowColor: Colors.lightBlueAccent.shade100,
                elevation: 5.0,
                child: MaterialButton(
                  minWidth: 200.0,
                  height: 42.0,
                  onPressed: () {
                    setState(() {
                      _castSender.disconnect();

                      connected = false;
                    });
                  },
                  color: Colors.black,
                  child: Text('Disconnect',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
