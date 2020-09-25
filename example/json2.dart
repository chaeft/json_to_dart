import 'dart:io';
import 'dart:convert';

import "package:path/path.dart" show dirname, join, normalize;
import '../lib/json_to_dart.dart';

Future main() async {
  // #docregion bind
  var server = await HttpServer.bind(
    InternetAddress.loopbackIPv4,
    4040,
  );
  
  // #enddocregion bind
  print('Listening on localhost:${server.port}');

  // #docregion listen
  await for (HttpRequest request in server) {
    if (request.method != 'POST' || request.headers.contentType?.mimeType != 'application/json' /*1*/) {
      request.response.write("¯\\_(ツ)_/¯");
      await request.response.close();
      continue;
    }

    try {
      String content = await utf8.decoder.bind(request).join();
      var data = jsonDecode(content) as Map;
      if (data['className'] == null || data['className'].length < 1 || data['jsonData'] == null) {
        request.response.write("¯\\_(ツ)_/¯");
        //request.response.write('{"success": false, "message": "empty parameter"}');
        await request.response.close();
        continue;
      }

      final classGenerator = new ModelGenerator(data['className']);
      //DartCode dartCode = classGenerator.generateDartClasses(JsonEncoder().convert(data['jsonData']));
      DartCode dartCode = classGenerator.generateDartClasses(data['jsonData']);

      request.response.write(dartCode.code);
      await request.response.close();
    } catch (e) {
      print(e);
      request.response.write("¯\\_(ツ)_/¯");
      //request.response
      //    ..statusCode = HttpStatus.internalServerError
      //    ..write('Exception during file I/O: $e.');
      await request.response.close();
      continue;
    }
    
  }
  // #enddocregion listen
}
