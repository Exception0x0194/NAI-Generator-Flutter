import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nai_casrand/data/models/api_request.dart';
import 'package:nai_casrand/data/models/payload_config.dart';
import 'package:nai_casrand/data/models/settings.dart';
import 'package:nai_casrand/data/services/api_service.dart';

void main() {
  test('existing settings use the official endpoint', () {
    expect(
        Settings.fromJson({}).generationEndpoint, Settings.defaultApiEndpoint);
  });

  test('custom endpoint survives export and import, blank restores default',
      () {
    final settings = Settings.fromJson({
      'api_endpoint': ' https://example.com/custom/generate?version=5 ',
    });
    final restored = Settings.fromJson(settings.toJson());
    expect(restored.generationEndpoint,
        'https://example.com/custom/generate?version=5');
    restored.apiEndpoint = ' ';
    expect(restored.generationEndpoint, Settings.defaultApiEndpoint);
    restored.debugApiEnabled = true;
    expect(restored.generationEndpoint, restored.debugApiPath);
  });

  test('invalid endpoint schemes and incomplete addresses are rejected', () {
    for (final value in [
      'example.com',
      'https://',
      'file:///tmp/image',
      'https://example.com/a b',
      'https://example.com/#fragment',
    ]) {
      expect(Settings.isValidApiEndpoint(value), isFalse, reason: value);
      final settings = Settings.fromJson({'api_endpoint': value});
      expect(() => settings.generationEndpoint, throwsFormatException);
    }
    expect(
        Settings.isValidApiEndpoint('http://localhost:5000/ai/generate-image'),
        isTrue);
  });

  test('generation posts JSON and authorization to the custom path', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    final endpoint = 'http://127.0.0.1:${server.port}/custom/generate';
    final example =
        jsonDecode(File('assets/json/example.json').readAsStringSync())
            as Map<String, dynamic>;
    final config = PayloadConfig.fromJson(example);
    config.settings.apiEndpoint = endpoint;
    config.settings.apiKey = 'test-key';
    final received = server.first.then((request) async {
      expect(request.method, 'POST');
      expect(request.uri.path, '/custom/generate');
      expect(request.headers.contentType?.mimeType, 'application/json');
      expect(request.headers.value('authorization'), 'Bearer test-key');
      expect(jsonDecode(await utf8.decoder.bind(request).join()),
          {'model': 'nai-diffusion-5-full'});
      request.response.add([1, 2, 3]);
      await request.response.close();
    });
    final response = await ApiService().fetchData(ApiRequest(
      endpoint: config.settings.generationEndpoint,
      proxy: '',
      headers: config.getHeaders(),
      payload: {'model': 'nai-diffusion-5-full'},
    ));
    await received;
    expect(response.data, [1, 2, 3]);
  });
}
