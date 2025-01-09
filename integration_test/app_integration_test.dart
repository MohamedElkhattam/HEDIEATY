  import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:hedieaty/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  group("End-to-End Testing", () {
    testWidgets('Create Event and Gift Test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.byKey(const Key('login')), findsOneWidget);
      await tester.tap(find.byKey(const Key('navigate_to_signp')));
      await tester.pumpAndSettle();
      //Signup Process
      expect(find.byKey(const Key('signup')), findsOneWidget);
      await tester.enterText(find.byKey(const Key('signupname')), 'Mohamed');
      await tester.enterText(
          find.byKey(const Key('signupemail')), 'medo3@test.com');
      await tester.enterText(
          find.byKey(const Key('phone_number')), '01100110011');
      await tester.enterText(find.byKey(const Key('signupPassword')), '123123');
      await tester.enterText(
          find.byKey(const Key('confirm_password')), '123123');
      await tester.tap(find.byKey(const Key('perform_signup')));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      // Perform login
      expect(find.byKey(const Key('login')), findsOneWidget);
      await tester.enterText(
          find.byKey(const Key('emailField')), 'medo3@test.com');
      await tester.enterText(find.byKey(const Key('passwordField')), '123123');
      await tester.tap(find.byKey(const Key('performLogin')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      //navigate to event creation
      expect(find.byKey(const Key('home')), findsOneWidget);
      await tester.tap(find.byKey(const Key('choose_event_or_gift')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('create_or_update_event')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('name')), 'Birthday Party');
      await tester.enterText(find.byKey(const Key('location')), 'Central Park');
      await tester.enterText(
          find.byKey(const Key('description')), 'New party with negro:) !');

      await tester.tap(find.byIcon(Icons.calendar_month));
      await tester.pumpAndSettle();
      await tester.tap(find.text('27'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('create_event')));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byKey(const Key('home')), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('bottom_navigation_bar')), findsOneWidget);
      await tester.tap(find.byKey(const Key('go_to_events')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('event_list')), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('find_event')), findsOneWidget);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('click_on_event')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('gift_list')), findsOneWidget);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('choose_operation')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('add_gift')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('gift_name')), 'Iphone');
      await tester.enterText(
          find.byKey(const Key('gift_category')), 'Mobile Phone');
      await tester.enterText(find.byKey(const Key('gift_price')), '500');
      await tester.enterText(find.byKey(const Key('gift_desc')),
          'Someone buy me this phone please');
      await tester.tap(find.byKey(const Key('create_gift')));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byKey(const Key('gift_list')), findsOneWidget);
    });
  });
}
