import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barber/main.dart';
import 'package:barber/core/app_state.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Capture 25 screens and complete booking, profile and promo journeys',
    (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      final routes = <String, String>{
        '01-welcome': '/welcome',
        '02-login': '/login',
        '03-sign-up': '/signup',
        '04-home': '/home',
        '05-search': '/search',
        '06-map': '/map',
        '07-map-point': '/map-small',
        '08-shop-details': '/shop',
        '09-shop-reviews': '/shop-reviews',
        '10-reviews': '/reviews',
        '11-booking': '/booking',
        '12-calendar': '/calendar',
        '13-select-service': '/services',
        '14-select-barber': '/barbers',
        '15-barber-profile': '/barber',
        '16-confirmation': '/confirmation',
        '17-confirmed': '/confirmed',
        '18-upcoming': '/reservations',
        '19-previous': '/previous',
        '20-profile': '/profile',
        '21-edit-profile': '/edit-profile',
        '22-change-password': '/password',
        '23-bonuses': '/bonuses',
        '24-promo-code': '/promo',
        '25-congratulations': '/congratulations',
      };
      await tester.pumpWidget(BarberApp(state: AppState(prefs)));
      await tester.pumpAndSettle();
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final imageContext = tester.element(find.byType(MaterialApp));
      await tester.runAsync(
        () => Future.wait(
          manifest
              .listAssets()
              .where((path) => path.startsWith('assets/images/'))
              .map((path) => precacheImage(AssetImage(path), imageContext)),
        ),
      );
      await tester.pumpAndSettle();
      await binding.convertFlutterSurfaceToImage();
      const captureOnly = String.fromEnvironment('CAPTURE_SCREEN');
      for (final entry in routes.entries) {
        if (captureOnly.isNotEmpty && entry.key != captureOnly) continue;
        await tester.pumpWidget(
          BarberApp(
            key: UniqueKey(),
            state: AppState(prefs),
            initialRoute: entry.value,
          ),
        );
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();
        if (entry.key == '13-select-service') {
          expect(find.byKey(const ValueKey('services-0')), findsOneWidget);
        }
        if (entry.key == '14-select-barber') {
          expect(find.byKey(const ValueKey('barbers-0')), findsOneWidget);
        }
        expect(tester.takeException(), isNull, reason: entry.key);
        debugPrint('Capturing ${entry.key}');
        final bytes = await binding.takeScreenshot(entry.key);
        final file = File(
          '${Directory.systemTemp.path}/barber-screenshots/${entry.key}.png',
        );
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes, flush: true);
        // Keep the driver response small; images are copied through adb after the run.
        binding.reportData?.remove('screenshots');
      }
      final state = AppState(prefs);
      await tester.pumpWidget(BarberApp(key: UniqueKey(), state: state));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Log In'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Log In'));
      await tester.pumpAndSettle();
      expect(find.text('Barbershops NY'), findsOneWidget);
      await tester.tap(find.text('Book a visit  →').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('time-12:45')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Beard Styling').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('services-4')));
      await tester.pumpAndSettle();
      expect(state.serviceIndex, 4);
      await tester.tap(find.text('Marjorie Williamson'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('barbers-2')));
      await tester.pumpAndSettle();
      expect(state.barberIndex, 2);
      await tester.tap(find.widgetWithText(FilledButton, 'Book'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Confirm'));
      await tester.pumpAndSettle();
      expect(find.text('Done!'), findsOneWidget);
      await tester.tap(find.text('My reservation'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Services: Re-style'), findsOneWidget);
      expect(AppState(prefs).reservations.first.serviceIndex, 4);
      await tester.tap(find.byTooltip('Profile'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'Alex Warren');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Alex Warren'), findsOneWidget);
      await tester.tap(find.text('My bonuses'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('I have promocode'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('promo-code')),
        '218876',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Activate'));
      await tester.pumpAndSettle();
      expect(find.text('Congratulations!'), findsOneWidget);
      expect(AppState(prefs).bonuses, 525);
      expect(tester.takeException(), isNull);
      await prefs.clear();
    },
  );
}
