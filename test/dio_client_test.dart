import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_clean_arch/data/datasources/dio_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockHttpClientAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{"ok": true}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('dio client should not crash when no access token is stored', () async {
    SharedPreferences.setMockInitialValues({});
    dioClient.httpClientAdapter = _MockHttpClientAdapter();

    final uri = Uri.parse('https://example.com/test');
    await expectLater(dioClient.getUri(uri), completes);
  });
}
