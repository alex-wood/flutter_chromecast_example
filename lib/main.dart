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
      title: 'Smack Vol 4: Face Offs',
      contentId: 'https://r4---sn-32o-5hne.googlevideo.com/videoplayback?c=WEB&itag=22&key=yt6&mn=sn-32o-5hne%2Csn-4g5e6nz7&mm=31%2C26&ms=au%2Conr&source=youtube&sparams=dur%2Cei%2Cgcr%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cexpire&mv=u&dur=8826.392&mt=1552552500&pl=47&txp=5535432&ei=ExOKXLCiOdDZgAeE75jACw&gcr=nl&ratebypass=yes&ip=2a02%3Aa447%3Af62f%3A1%3Af0d5%3A7376%3Ac27%3Ac41d&requiressl=yes&lmt=1549872630116149&ipbits=0&fvip=4&id=o-ACYjjnMWu_n2AUSKplEU0mUcFTSmSE-y0kdDLCOLyowI&mime=video%2Fmp4&expire=1552574324&signature=AF60D130215AD79C7FD31D21336FA0A01DF0A6B2.5215A0135267B74035DB180A4080AA0C473DA368',
      images: ['https://t2.genius.com/unsafe/391x220/https%3A%2F%2Fimages.genius.com%2Fe63b2a6eaa16af5ce8d8df0f133cd9df.1000x563x1.jpg'],
    ),
    CastMedia(
      title: 'Mr. Wavy Vs Brizz',
      contentId: 'https://player.vimeo.com/external/306670679.m3u8?s=16690c48a5368404315153303dd696dd4b7fb17c',
      images: ['https://i.ytimg.com/vi/dCfOxU1uFK8/maxresdefault.jpg']
    )
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


    setState(() {

    });

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
              icon: Icon(Icons.cast),
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
                        onDevicePicked: _connectToDevice)
                );
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
                FlatButton(child: Icon(Icons.fast_rewind), onPressed: (){

                  //rewind 10 seconds from current video position
                  _castSender.seek(_castSender
                      .castSession.castMediaStatus.position - 10.0);
                },),
                FlatButton(child: Icon(Icons.play_arrow), onPressed: (){
                  _castSender.togglePause();
                },),
                FlatButton(child: Icon(Icons.stop), onPressed: (){
                  _castSender.disconnect();
                },),
                FlatButton(child: Icon(Icons.fast_forward), onPressed: (){
                  //fast forward 10 seconds from current video position
                  _castSender.seek(_castSender
                      .castSession.castMediaStatus.position + 10.0);
                },),
              ],
            ),
            connected ? FlatButton(child: Icon(Icons.close), onPressed: (){
              _castSender.disconnect();
              setState(() {
                connected = false;
              });
            },) : Container(),
          ],
        ),
      );
    });
  }
}
