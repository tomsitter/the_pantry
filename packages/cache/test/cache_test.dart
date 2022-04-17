import 'package:cache/cache.dart';
import 'package:test/test.dart';

void main() {
  group('Cache', () {
    test('Can add and retrieve items', () {
      CacheClient cache = CacheClient();
      String key = '__key__';
      String value = '__value__';

      expect(cache.read(key: key), isNull);
      cache.write(key: key, value: value);
      expect(cache.read(key: key), equals(value));
      expect(cache.read(key: 'some other key'), isNull);
    });
  });
}