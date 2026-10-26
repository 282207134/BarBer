import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barber/main.dart';
import 'package:barber/core/app_state.dart';

const routes = [
  '/welcome',
  '/login',
  '/signup',
  '/home',
  '/search',
  '/map',
  '/map-small',
  '/shop',
  '/shop-reviews',
  '/reviews',
  '/booking',
  '/calendar',
  '/services',
  '/barbers',
  '/barber',
  '/confirmation',
  '/confirmed',
  '/reservations',
  '/previous',
  '/profile',
  '/edit-profile',
  '/password',
  '/bonuses',
  '/promo',
  '/congratulations',
];
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final font in {
      'ArchivoBlack': 'ArchivoBlack-Regular.ttf',
      'Roboto': 'Roboto.ttf',
    }.entries) {
      await (FontLoader(
        font.key,
      )..addFont(rootBundle.load('assets/fonts/${font.value}'))).load();
    }
  });
  testWidgets('All 25 routes render at reference and compact phone sizes', (
    tester,
  ) async {
    for (final size in [const Size(414, 896), const Size(360, 780)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      for (final route in routes) {
        SharedPreferences.setMockInitialValues({});
        final state = AppState(await SharedPreferences.getInstance());
        await tester.pumpWidget(
          BarberApp(key: UniqueKey(), state: state, initialRoute: route),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$route at $size');
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        state.dispose();
      }
    }
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });
  testWidgets('Login rejects invalid email', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState(await SharedPreferences.getInstance());
    await tester.pumpWidget(BarberApp(state: state, initialRoute: '/login'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'invalid');
    await tester.tap(find.widgetWithText(FilledButton, 'Log In'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(state.signedIn, isFalse);
  });
}
