import 'dart:io';

import 'package:e_trace_app/base/api/api_configuration.dart';
import 'package:e_trace_app/base/api/api_endpoint.dart';
import 'package:http/http.dart' as http;
import 'package:e_trace_app/screen/profile/change_photo_response.dart';
import 'package:http/io_client.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

class ChangeProfileRepository {
  String baseUrl;
  IOClient ioClient;

  ChangeProfileRepository(String baseUrl) {
    this.baseUrl = baseUrl;
    HttpClient httpClient =  HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
    this.ioClient =  IOClient(httpClient);
  }

  void doChangePhotoProfile(String token, PickedFile image, onSuccess, onError) async {
    var stream = http.ByteStream(image.openRead());
    File imageFile = File(image.path);
    var length = await imageFile.length();
    try {
      var url = baseUrl + APIEndpoint.CHANGE_PHOTO_ENDPOINT;
      var uri = Uri.parse(url);
      var request =  http.MultipartRequest("POST", uri);
      request.headers.addAll(APIConfiguration(baseUrl).getDefaultHeaderFormWithToken(token));
      var mimeContent = lookupMimeType(
          '${image.path.toString().substring(image.path.toString().length - 20)}');
      var typeMedia = mimeContent.substring(0, mimeContent.indexOf('/', 0));
      var pos = mimeContent.indexOf('/', 0);
      var subTypeMedia = mimeContent.substring(pos + 1, mimeContent.length);
      var multipartFile =  http.MultipartFile('image', stream, length,
          filename: basename(image.path),
          contentType: MediaType(typeMedia, subTypeMedia));
      request.files.add(multipartFile);
      var response = await request.send();
      response.stream.transform(utf8.decoder).listen((value) {
        String responseJson = value;
        Map<String, dynamic> dataMedia = json.decode(responseJson);

        ChangePhotoResponse apiResponse = ChangePhotoResponse.fromJson(dataMedia);
        if (apiResponse.success == true) {
          onSuccess(apiResponse);
        } else {
          onError(apiResponse);
        }
        print(responseJson);
      });
    } catch (exception) {
      onError(exception.toString());
    }
  }
}
