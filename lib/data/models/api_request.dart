class ApiResponse {
  final String status;
  final dynamic data;

  const ApiResponse({
    required this.status,
    required this.data,
  });
}

class ApiRequest {
  final String endpoint;
  final String proxy;
  final Map<String, dynamic> payload;

  const ApiRequest({
    required this.endpoint,
    required this.proxy,
    required this.payload,
  });
}
