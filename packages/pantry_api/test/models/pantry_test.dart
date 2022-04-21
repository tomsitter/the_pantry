import 'package:test/test.dart';
import 'package:pantry_api/pantry_api.dart';

class TestPantryApi extends PantryApi {
  TestPantryApi() : super();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

void main() {
  group('Pantry API', () {
    test('can be constructed', () {
      expect(TestPantryApi.new, returnsNormally);
    });
  });
}
