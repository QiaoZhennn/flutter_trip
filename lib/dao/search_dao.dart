
import 'dart:convert';

import 'package:flutter_trip/model/home_model.dart';
import 'package:flutter_trip/model/search_model.dart';
import 'package:http/http.dart' as http;
const HOME_URL = 'http://www.devio.org/io/flutter_app/json/home_page.json';

class SearchDao{
  static Future<SearchModel> fetch(String url, String text) async {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      Utf8Decoder utf8decoder = Utf8Decoder();
      var result = json.decode(utf8decoder.convert(response.bodyBytes));
      // front end may send requests very frequent, back end may return a
      // json that are not the front requested
      // need to do a match here to ensure return a correct result
      SearchModel model = SearchModel.fromJson(result);
      model.keyword = text;
      return model;
    } else {
      throw Exception('Fail to load search.json');
    }
  }
}