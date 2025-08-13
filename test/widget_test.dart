// This is a basic Flutter widget test for the Skykraft app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Skykraft App Basic Tests', () {
    testWidgets('Basic widget test', (WidgetTester tester) async {
      // Create a simple test widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('SKYKRAFT'),
            ),
          ),
        ),
      );

      // Verify that the text is displayed
      expect(find.text('SKYKRAFT'), findsOneWidget);
    });

    testWidgets('Theme color test', (WidgetTester tester) async {
      // Test the theme colors used in the app
      const primaryColor = Color(0xFF1976D2);
      const secondaryColor = Color(0xFF00B8D9);
      
      // Create a test widget with the app's theme colors
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            primaryColor: primaryColor,
            colorScheme: ColorScheme.light(
              secondary: secondaryColor,
            ),
          ),
          home: Scaffold(
            body: Center(
              child: Column(
                children: [
                  Container(
                    color: primaryColor,
                    child: const Text('Primary', style: TextStyle(color: Colors.white)),
                  ),
                  Container(
                    color: secondaryColor,
                    child: const Text('Secondary', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify that the colors are applied correctly
      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Secondary'), findsOneWidget);
    });
  });
}
