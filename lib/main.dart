import 'dart:io';
import 'package:graduation_app/customs/background.dart';

import 'get_from_cloud.dart';
import 'image_recognition.dart';
import 'package:flutter/material.dart';
import 'image_paint_page.dart';
import 'globals.dart' as globals;
import 'sound.dart';
import 'live_stream_video.dart';
import 'UIassets/constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MaterialApp(
  home: Splash(),
  routes:<String, WidgetBuilder>{
  '/camera':(context)  => MainMenu(),
  '/stream':(context)  => CameraApp(),
  '/draw_image':(context) => ImageAndSound(),
  '/get_cloud':(context) => GetCloud(),
},));
}

class Splash extends StatefulWidget{
  const Splash({Key? key}) : super(key:key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState(){
    super.initState();
    gotomain();
  }
  gotomain()async{
    await Future.delayed(const Duration(seconds: 4),(){});
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> MainMenu()));
  }

  @override
  Widget build(BuildContext context) {
    final Size size= MediaQuery.of(context).size;
    return MaterialApp(

      home: Scaffold(
          backgroundColor: themeColor,
          body: Center(
            child: Column(
              children: [Image.asset('assets/mainpage.png',height: size.height/1.5,width: size.width,),
              const SpinKitWave(
                color: WHITE
              ),
              ]
            ),
          )
      ),
    );
    throw UnimplementedError();
  }
}

