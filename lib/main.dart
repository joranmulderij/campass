import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  runApp(MaterialApp(
    home: HomeScreen(),
    color: Color(0xff3DDC84),
    theme:
        ThemeData(primaryColor: Color(0xff3DDC84), primarySwatch: Colors.green),
  ));
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CameraController cameraController;
  ScrollController scrollController = ScrollController();
  static const Map<int, String> headings = {
    0: 'N',
    90: 'E',
    180: 'S',
    270: 'W',

    45: 'NE',
    135: 'SE',
    225: 'SW',
    315: 'NW',

    360: 'N',
  };

  @override
  void initState() {
    super.initState();
    cameraController =
        CameraController(cameras[0], ResolutionPreset.max, enableAudio: false);
    cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });

    FlutterCompass.events!.listen((event) {
      print(event.headingForCameraMode);
      if (event.headingForCameraMode == null) return;

      if (scrollController.hasClients)
        scrollController.animateTo(event.headingForCameraMode! * 6,
            duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  AppBar get appBar => AppBar(
    title: Text('Campass'),
    leading: Image.asset(
      'assets/icon.png',
    ),
    leadingWidth: 50,
    actions: [
      Builder(builder: (context) {
        return IconButton(
          icon: Icon(Icons.help),
          onPressed: () {
            showAboutDialog(
              context: context,
              applicationName: 'Campass',
              applicationIcon: Image.asset(
                'assets/icon.png',
                width: 100,
              ),
              applicationVersion: '1.0.0',
              applicationLegalese: 'A Camera Compass',
              children: [
                ListTile(
                  title: Text('Made by Joran Mulderij'),
                  subtitle: Text('github.com/joranmulderij'),
                ),
              ],
            );
          },
        );
      }),
    ],
  );

  @override
  Widget build(BuildContext context) {
    if(cameras.length == 0)
      return Scaffold(
        appBar: appBar,
        body: Center(
          child: Text('No Cameras Found!'),
        ),
      );
    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          GestureDetector(
            onTap: (){
              cameraController.setFocusMode(FocusMode.auto);
            },
            child: Builder(
              builder: (context) {
                if (!cameraController.value.isInitialized) {
                  return Container();
                }
                return MaterialApp(
                  home: CameraPreview(cameraController),
                );
              },
            ),
          ),
          LayoutBuilder(builder: (context, constraints) {
            return ListView(
              children: [
                SizedBox(
                  width: constraints.maxWidth / 2,
                ),
                for (int i = 0; i <= 360; i += 5)
                  Container(
                    width: 30,
                    child: Text(headings.containsKey(i) ? '${headings[i]}\n\nl\n$i\nl' : '\n\nl\n$i\nl'),
                  ),
                SizedBox(
                  width: constraints.maxWidth / 2,
                ),
              ],
              scrollDirection: Axis.horizontal,
              controller: scrollController,
              physics: NeverScrollableScrollPhysics(),
            );
          }),
          Align(
            child: Column(
              children: [
                Icon(Icons.arrow_drop_down),
                SizedBox(
                  height: 65,
                ),
                Icon(Icons.arrow_drop_up),
              ],
            ),
            alignment: Alignment.topCenter,
          ),
          Align(
            alignment: Alignment.center,
            child: RotatedBox(
              quarterTurns: 1,
              child: Divider(
                thickness: 1,
                color: Colors.black38,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
