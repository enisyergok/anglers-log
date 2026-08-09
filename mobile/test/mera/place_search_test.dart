import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/mera/place_search.dart';

void main() {
  test('parses lat,lng coordinates without network', () async {
    final hits = await PlaceSearch.search('41.015137, 28.979530');
    expect(hits, hasLength(1));
    expect(hits.first.lat, closeTo(41.015137, 0.00001));
    expect(hits.first.lng, closeTo(28.979530, 0.00001));
  });

  test('rejects empty query', () async {
    expect(await PlaceSearch.search(' '), isEmpty);
  });
}
