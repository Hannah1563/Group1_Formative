// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:group1_formative/main.dart';

void main() {
  testWidgets('App boots and bottom navigation switches tabs',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Bottom nav labels exist.
    final nav = find.byType(BottomNavigationBar);
    expect(
      find.descendant(of: nav, matching: find.text('Dashboard')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: nav, matching: find.text('Assignments')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: nav, matching: find.text('Schedule')),
      findsOneWidget,
    );

    // Starts on Dashboard.
    final appBar = find.byType(AppBar);
    expect(find.descendant(of: appBar, matching: find.text('Dashboard')),
        findsOneWidget);

    // Switch to Assignments tab.
    await tester.tap(find.text('Assignments'));
    await tester.pumpAndSettle();
    expect(find.descendant(of: appBar, matching: find.text('Assignments')),
        findsOneWidget);

    // Switch to Schedule tab.
    await tester.tap(find.text('Schedule'));
    await tester.pumpAndSettle();
    expect(find.descendant(of: appBar, matching: find.text('Schedule')),
        findsOneWidget);
  });
}
