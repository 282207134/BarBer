import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models.dart';

class AppState extends ChangeNotifier {
  AppState(this.preferences) {
    name = preferences.getString('name') ?? 'Colleen Warren';
    email = preferences.getString('email') ?? 'c.warren@example.com';
    phone = preferences.getString('phone') ?? '(262) 555-0131';
    bonuses = preferences.getInt('bonuses') ?? 475;
    promoUsed = preferences.getBool('promoUsed') ?? false;
    signedIn = preferences.getBool('signedIn') ?? false;
    final raw = preferences.getString('reservations');
    if (raw != null) {
      try {
        reservations.addAll(
          (jsonDecode(raw) as List).map((j) => Reservation.fromJson(j)),
        );
      } on FormatException {
        preferences.remove('reservations');
      }
    } else {
      reservations.add(
        Reservation(
          id: 'demo',
          date: DateTime.now().add(const Duration(days: 3)),
          time: '12:00',
          serviceIndex: 1,
          barberIndex: 0,
          shopIndex: 0,
        ),
      );
    }
  }
  final SharedPreferences preferences;
  late String name, email, phone;
  late int bonuses;
  late bool signedIn, promoUsed;
  DateTime date = DateUtils.dateOnly(
    DateTime.now().add(const Duration(days: 2)),
  );
  String time = '12:00';
  int serviceIndex = 1, barberIndex = 0, shopIndex = 0;
  final List<Reservation> reservations = [];
  int userRating = 0;
  String userReview = '';
  Service get service => services[serviceIndex];
  Barber get barber => barbers[barberIndex];
  Shop get shop => shops[shopIndex];

  Future<void> authenticate(String value) async {
    email = value;
    signedIn = true;
    await preferences.setString('email', email);
    await preferences.setBool('signedIn', true);
    notifyListeners();
  }

  Future<void> logout() async {
    signedIn = false;
    await preferences.setBool('signedIn', false);
    notifyListeners();
  }

  void select({
    DateTime? day,
    String? slot,
    int? service,
    int? barber,
    int? shop,
  }) {
    date = day ?? date;
    time = slot ?? time;
    serviceIndex = service ?? serviceIndex;
    barberIndex = barber ?? barberIndex;
    shopIndex = shop ?? shopIndex;
    notifyListeners();
  }

  Future<bool> book() async {
    if (reservations.any(
      (r) =>
          DateUtils.isSameDay(r.date, date) &&
          r.time == time &&
          r.barberIndex == barberIndex,
    )) {
      return false;
    }
    reservations.insert(
      0,
      Reservation(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        date: date,
        time: time,
        serviceIndex: serviceIndex,
        barberIndex: barberIndex,
        shopIndex: shopIndex,
      ),
    );
    await _saveReservations();
    notifyListeners();
    return true;
  }

  Future<void> cancel(String id) async {
    reservations.removeWhere((r) => r.id == id);
    await _saveReservations();
    notifyListeners();
  }

  Future<void> _saveReservations() => preferences.setString(
    'reservations',
    jsonEncode(reservations.map((r) => r.toJson()).toList()),
  );
  Future<void> saveProfile(
    String newName,
    String newPhone,
    String newEmail,
  ) async {
    name = newName;
    phone = newPhone;
    email = newEmail;
    await Future.wait([
      preferences.setString('name', name),
      preferences.setString('phone', phone),
      preferences.setString('email', email),
    ]);
    notifyListeners();
  }

  Future<bool> activatePromo(String code) async {
    if (promoUsed || code.replaceAll(RegExp(r'\D'), '') != '218876') {
      return false;
    }
    promoUsed = true;
    bonuses += 50;
    await preferences.setBool('promoUsed', true);
    await preferences.setInt('bonuses', bonuses);
    notifyListeners();
    return true;
  }

  void review(int rating, String text) {
    userRating = rating;
    userReview = text;
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);
  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
