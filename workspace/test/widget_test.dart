import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:echoes/main.dart';

void main() {
  testWidgets('Echoes app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EchoesApp());

    // Verify that the app loads successfully
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}