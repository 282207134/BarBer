import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barber/core/app_state.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'Booking selections persist, duplicate is rejected, cancellation persists',
    () async {
      final prefs = await SharedPreferences.getInstance(),
          state = AppState(await SharedPreferences.getInstance());
      state.select(slot: '14:15', service: 4, barber: 2, shop: 1);
      expect(await state.book(), isTrue);
      expect(await state.book(), isFalse);
      final restored = AppState(prefs);
      expect(restored.reservations.first.serviceIndex, 4);
      expect(restored.reservations.first.barberIndex, 2);
      expect(restored.reservations.first.shopIndex, 1);
      final id = restored.reservations.first.id;
      await restored.cancel(id);
      expect(AppState(prefs).reservations.any((r) => r.id == id), isFalse);
    },
  );
  test('Profile and session survive reload without storing password', () async {
    final prefs = await SharedPreferences.getInstance(),
        state = AppState(await SharedPreferences.getInstance());
    await state.authenticate('test@example.com');
    await state.saveProfile('Alex Smith', '1234567890', 'alex@example.com');
    final restored = AppState(prefs);
    expect(restored.name, 'Alex Smith');
    expect(restored.email, 'alex@example.com');
    expect(restored.signedIn, isTrue);
    expect(prefs.getKeys().any((key) => key.contains('password')), isFalse);
    await restored.logout();
    expect(AppState(prefs).signedIn, isFalse);
  });
  test('Promo adds 50 points once and survives reload', () async {
    final prefs = await SharedPreferences.getInstance(),
        state = AppState(await SharedPreferences.getInstance());
    expect(await state.activatePromo('000000'), isFalse);
    expect(await state.activatePromo('218876'), isTrue);
    expect(state.bonuses, 525);
    expect(await AppState(prefs).activatePromo('218876'), isFalse);
    expect(AppState(prefs).bonuses, 525);
  });
}
