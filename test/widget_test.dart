import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/main.dart';

void main() {
  testWidgets('App loads', (tester) async {
    await tester.pumpWidget(const MyApp());
  });
}
