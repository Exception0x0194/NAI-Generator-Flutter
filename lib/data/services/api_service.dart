import 'dart:convert';

import 'package:nai_casrand/data/models/api_request.dart';

class RequestService {
  Future<ApiResponse> fetchData(ApiRequest request) async {
    final url = Uri.parse(request.endpoint);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.payload),
    );

    if (response.statusCode == 200) {
      return ApiResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load data');
    }
  }
}
