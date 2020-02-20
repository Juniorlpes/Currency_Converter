import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiRequest {

  String request = "https://api.hgbrasil.com/finance?format=json&key=c8d612a9";

  Future<Map> getData() async {
    http.Response response = await http.get(request);
    return json.decode(response.body);
  }

}