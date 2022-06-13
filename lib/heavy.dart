import 'dart:convert';
import 'dart:developer';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter_isolate_example/photo_data.dart';
import 'package:http/http.dart' as http;

class Heavy {
  bool useCompute;
  bool usePersistentIsolate;
  late Isolate isolate;
  late SendPort _sendPort;
  Heavy({this.useCompute = false, this.usePersistentIsolate = false}) {
    ReceivePort myReceivePort = ReceivePort();
    Isolate.spawn(isolateEntryPoint, myReceivePort.sendPort).then((value) {
      isolate = value;
    });
    myReceivePort.first.then((value) {
      _sendPort = value;
    });
  }

  Future<void> recursiveHeavyFunction() async {
    await Future.delayed(const Duration(seconds: 2));
    String jsonString = await getJsonData();
    for (int i = 0; i < 80; i++) {
      if (useCompute) {
        List<PhotoData> parsedData =
            await compute(parseJsonToModel, jsonString);
        log("parsing jsonString[$i] done... parsed length :${parsedData.length}");
      } else if (usePersistentIsolate) {
        //Setup new receive port to get data back from isolate
        ReceivePort receivePort = ReceivePort();
        _sendPort.send([jsonString, receivePort.sendPort]);
        List<PhotoData> parsedData = await receivePort.first;
        log("parsing jsonString[$i] done... parsed length :${parsedData.length}");
      } else {
        List<PhotoData> parsedData = parseJsonToModel(jsonString);
        log("parsing jsonString[$i] done... parsed length :${parsedData.length}");
      }
    }
    recursiveHeavyFunction();
  }

  Future<String> getJsonData() async {
    var response = await http
        .get(Uri.parse("https://jsonplaceholder.typicode.com/photos"));
    return response.body;
  }

  List<PhotoData> parseJsonToModel(String json) {
    Iterable<dynamic> data = jsonDecode(json);
    return data.map((e) => PhotoData.fromMap(e)).toList();
  }

  void isolateEntryPoint(SendPort sendPort) async {
    //Set up receiver port for sending send port to outside
    ReceivePort receivePort = ReceivePort();
    //Send send port to outside through the send port that is passed in
    sendPort.send(receivePort.sendPort);
    await for (var message in receivePort) {
      String jsonString = message[0] as String;
      final SendPort sendBackPort = message[1] as SendPort;
      List<PhotoData> parsedData = parseJsonToModel(jsonString);
      sendBackPort.send(parsedData);
    }
  }

  void dispose() {
    isolate.kill();
  }
}
