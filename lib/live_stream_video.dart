import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'dart:io';
import 'package:image/image.dart' as imoo;
import 'image_paint_page.dart';
import 'globals.dart' as globals;

late List<CameraDescription> cameras;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class RectanglePainter1 extends CustomPainter {
  var parsedata;
  @override
  void paint(Canvas canvas, Size size) {
    //------------------------------------------
    parsedata = globals.parsedata;
    final widthRatio = 1.5;
    final heightRatio = 1.5;
    double fontSize = 0.05 * size.width;
    for (var dict in parsedata) {
      final a = Offset(dict['xmin'] * widthRatio, dict['ymin'] * heightRatio);
      final b = Offset(dict['xmax'] * widthRatio, dict['ymax'] * heightRatio);
      //drawing rectangle with point a and b
      final rect = Rect.fromPoints(a, b);
      Color predectionColor = Color.fromARGB(255, 200, 200, 200);

      final paint = Paint()
        ..color = predectionColor
        ..strokeWidth = 0.003 * (size.width + size.height)
        ..style = PaintingStyle.stroke;
      canvas.drawRect(rect, paint);
      //------------------------------------------
      //Add name of the predicted object over it's square in the image
      TextSpan span = new TextSpan(
          style: new TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: fontSize,
              backgroundColor: predectionColor,
              fontFamily: 'Roboto'),
          text: " " + dict['name'] + " ");

      TextPainter tp = new TextPainter(
          text: span,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center);

      tp.layout();
      tp.paint(
          canvas,
          new Offset(dict['xmin'] * widthRatio,
              dict['ymin'] * heightRatio - fontSize - 5));
      //------------------------------------------
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(CameraApp());
}

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  Future<void> camera_starter() async {
    HttpOverrides.global = MyHttpOverrides();
    WidgetsFlutterBinding.ensureInitialized();

    cameras = await availableCameras();

    runApp(CameraApp());
  }

  late CameraImage cameraImage;
  late CameraController controller;
  var image = null;
  bool start = false;
  late List<Plane> image_send;
  late int test = 70;

  get jpeg => null;
  var image_show_1;

  @override
  void initState() {
    super.initState();
    camera_starter();
    loadCamera();
  }

  loadCamera() {
    controller = CameraController(cameras[0], ResolutionPreset.low,
        imageFormatGroup: ImageFormatGroup.jpeg);

    controller.initialize().then((_) {
      IO.Socket socket = IO.io('${globals.domain}/test',
          OptionBuilder().setTransports(['websocket']).build());
      socket.onConnect((_) {
        print('connect!!!!!!!!!!!!!!!!!!!!!!!');
      });

      if (!mounted) {
        return;
      } else {
        setState(() {
          int counter = 0;

          controller.startImageStream((image) {
            cameraImage = image;
            counter = counter + 1;
            if (counter % 20 == 0) {
              globals.width = image.width;
              globals.height = image.height;
              var imaaaage = base64Encode(image.planes[0].bytes);
              socket.emit('input image array', imaaaage);
              setState(() {
                globals.parsedata = [];
              });
            }
          });
        });
      }

      socket.on('out-image-event-array', (data) {
        final parsed = json.decode(data);
        globals.parsedata = parsed;

        setState(() {
          image_show_1 = RectanglePainter1();
          globals.st = true;
        });
      });

      socket.onDisconnect((_) => print('disconnect'));
    });
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Live Object Detection'),
        ),
        body: Center(
            child: globals.st
                ? CustomPaint(
                    foregroundPainter: image_show_1,
                    child: CameraPreview(controller),
                  )
                : CameraPreview(controller)),
      ),
    );
  }
}
