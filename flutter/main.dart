import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //final Future<FirebaseApp> _firebaseApp = Firebase.initializeApp();
  final fb = FirebaseDatabase.instance;
  String realTimeValue = '0';
  String humidityy = '0';
  //String temperature = '0';
  String rain = '1024';
  bool value = false;
  bool auto = false;

  @override
  void initState() {
    super.initState();

    fb.ref().child('switch').onValue.listen((event) {
      var snapshot = event.snapshot;

      dynamic resp = snapshot.value;
      setState(() {
        value = resp["switch"];
      });
    });

    fb.ref().child('auto').onValue.listen((event) {
      var snapshott = event.snapshot;
      dynamic respp = snapshott.value;
      setState(() {
        auto = respp["auto"];
      });
    });
  }

  Expanded rainData(String mainText) {
    return Expanded(
      child: SizedBox(
        child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 7,
          color: Color(0xFF302579),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Center(
              child: Expanded(
                  child: Row(
            children: [
              Expanded(
                  child: Container(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 5),
                      child: Text(
                        "Rain Notification",
                        style: GoogleFonts.cabin(
                          fontSize: 23,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 20,
                        child: FirebaseAnimatedList(
                            query: fb.ref().child('Sensor'),
                            shrinkWrap: true,
                            defaultChild: Text('Loading'),
                            itemBuilder: (context, snapshot, animation, index) {
                              String rainText;
                              int rainValue = int.parse(
                                  snapshot.child('Rain').value.toString());
                              if (rainValue > 800) {
                                rainText = "Sunny";
                              } else if (rainValue <= 800 && rainValue > 600) {
                                rainText = "Light Rain";
                              } else if (rainValue <= 600 && rainValue > 460) {
                                rainText = "Medium Rain";
                              } else {
                                rainText = "Heavy Rain";
                              }
                              return Text(
                                rainText,
                                style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 22,
                                        color: Colors.white)),
                              );
                            }),
                      ),
                    )
                  ],
                ),
              )),
              Expanded(
                flex: 1,
                child: Container(
                  child: FirebaseAnimatedList(
                      query: fb.ref().child('Sensor'),
                      shrinkWrap: true,
                      defaultChild: Text('Loading'),
                      itemBuilder: (context, snapshot, animation, index) {
                        String rainText;
                        int rainValue =
                            int.parse(snapshot.child('Rain').value.toString());
                        if (rainValue > 800) {
                          rainText = "assets/sunnyv2.png";
                        } else if (rainValue <= 800 && rainValue > 600) {
                          rainText = "assets/lrainv1.png";
                        } else if (rainValue <= 600 && rainValue > 460) {
                          rainText = "assets/midrainv3.png";
                        } else {
                          rainText = "assets/heavyrain.png";
                        }
                        return Container(
                          //margin: EdgeInsets.all(60),
                          //padding: EdgeInsets.all(0),
                          child: Image.asset(
                            rainText,
                            isAntiAlias: true,
                            scale: 3,
                          ),
                        );
                      }),
                ),
              )
            ],
          ))),
        ),
        // margin:
        //     EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0, bottom: 10.0),
        // decoration: getBoxDecoration(),
      ),
    );
  }

  Expanded humData(String mainText) {
    return Expanded(
      child: SizedBox(
        child: Card(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            elevation: 7,
            color: Color(0xFF302579),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Expanded(
              child: Center(
                  child: FirebaseAnimatedList(
                query: fb.ref().child('DHThum'),
                shrinkWrap: true,
                defaultChild: Text("Loading"),
                itemBuilder: ((context, snapshot, animation, index) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                          child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.ideographic,
                            children: [
                              Text(snapshot.child('hum').value.toString(),
                                  style: GoogleFonts.cabin(
                                      textStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 30,
                                          color: Colors.white))),
                              Text(
                                "%",
                                style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                        color: Colors.white)),
                              )
                            ],
                          ),
                          Text(
                            mainText,
                            style: GoogleFonts.cabin(
                              textStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      )),
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: RotationTransition(
                          turns: AlwaysStoppedAnimation(180 / 360),
                          child: CircularProgressIndicator(
                            value: double.parse(
                                    snapshot.child('temp').value.toString()) /
                                100,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            backgroundColor: Colors.black45,
                            strokeWidth: 10,
                          ),
                        ),
                      )
                    ],
                  );
                }),
              )),
            )),
      ),
    );
  }

  Expanded tempData(String mainText) {
    return Expanded(
      child: SizedBox(
        child: Card(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            elevation: 7,
            color: Color(0xFF302579),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Expanded(
              child: Center(
                  child: FirebaseAnimatedList(
                query: fb.ref().child('DHTTemp'),
                shrinkWrap: true,
                defaultChild: Text("Loading"),
                itemBuilder: ((context, snapshot, animation, index) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                          child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.ideographic,
                            children: [
                              Text(snapshot.child('temp').value.toString(),
                                  style: GoogleFonts.cabin(
                                      textStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 30,
                                          color: Colors.white))),
                              Text(
                                "C",
                                style: GoogleFonts.cabin(
                                    textStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                        color: Colors.white)),
                              )
                            ],
                          ),
                          Text(
                            mainText,
                            style: GoogleFonts.cabin(
                              textStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      )),
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: RotationTransition(
                          turns: AlwaysStoppedAnimation(180 / 360),
                          child: CircularProgressIndicator(
                            value: double.parse(
                                    snapshot.child('temp').value.toString()) /
                                100,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            backgroundColor: Colors.black45,
                            strokeWidth: 10,
                          ),
                        ),
                      )
                    ],
                  );
                }),
              )),
            )),
      ),
    );
  }

  Expanded roofSwitch(String mainText) {
    return Expanded(
      child: SizedBox(
        child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 7,
          color: Color(0xFF302579),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text("$mainText ${value ? "Open" : "Close"}",
                      style: GoogleFonts.cabin(
                        textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white),
                      )),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: SizedBox(
                    width: 80,
                    height: 45,
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        updateRoofSwitch();
                      },
                      label: value ? Text("Close") : Text("Open"),
                      elevation: 5,
                      backgroundColor:
                          value ? Colors.redAccent : Color(0xFF2bb500),

                      // icon: value
                      //     ? Icon(Icons.beach_access)
                      //     : Icon(Icons.beach_access_rounded),
                    ),
                  ),
                )
              ],
            ),
          ),
          // margin:
          //     EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0, bottom: 10.0),
          // decoration: getBoxDecoration(),
        ),
      ),
    );
  }

  Expanded autoSwitch(String mainText) {
    return Expanded(
      child: SizedBox(
        child: Card(
          color: Color(0xFF302579),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text("${auto ? "Manual" : "Automatic"} $mainText",
                      style: GoogleFonts.cabin(
                        textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white),
                      )),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: SizedBox(
                    width: 90,
                    height: 45,
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        updateAutoSwitch();
                      },
                      label: auto ? Text("Automatic") : Text("Manual"),
                      elevation: 5,
                      backgroundColor:
                          auto ? Colors.redAccent : Color(0xFF2bb500),
                      // icon: value
                      //     ? Icon(Icons.beach_access)
                      //     : Icon(Icons.beach_access_rounded),
                    ),
                  ),
                )
              ],
            ),
          ),
          // margin:
          //     EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0, bottom: 10.0),
          // decoration: getBoxDecoration(),
        ),
      ),
    );
  }

  void updateRoofSwitch() async {
    DatabaseReference _roofRef = FirebaseDatabase.instance.ref();

    await _roofRef.child("switch").set({"switch": !value}).then((value) {
      setState(() {});
    }).onError((error, stackTrace) {
      print("failed " + error.toString());
    });
  }

  void updateAutoSwitch() async {
    DatabaseReference _autoRef = FirebaseDatabase.instance.ref();

    await _autoRef.child("auto").set({"auto": !auto}).then((auto) {
      setState(() {});
    }).onError((error, stackTrace) {
      print("failed " + error.toString());
    });
  }

  Future<dynamic> manualRoof() async {
    DatabaseReference _roofRef = FirebaseDatabase.instance.ref();

    return await _roofRef.child("switch").get();
  }

  Future<dynamic> autoRoof() async {
    DatabaseReference _roofRef = FirebaseDatabase.instance.ref();

    return await _roofRef.child("auto").get();
  }

  Widget content() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        height: MediaQuery.of(context).size.height,
        color: Colors.grey.shade300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [tempData('Temperature'), humData('Humidity')],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [rainData('Rain Sensor')],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                //children: [getExpanded('rain', 'Switch')],
                children: [roofSwitch('mainText')],
              ),
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF302579),
          centerTitle: true,
          title: Text(
            "Hava",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        body: Container(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            height: MediaQuery.of(context).size.height,
            color: Color(0xFF4e55a1),
            //color: Color(0xFF444444),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [tempData('Temperature'), humData('Humidity')],
                  ),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [rainData('Rain Sensor')],
                  ),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    //children: [getExpanded('rain', 'Switch')],
                    children: [roofSwitch('Roof'), autoSwitch('Mode')],
                  ),
                ),
              ],
            )));
  }
}
