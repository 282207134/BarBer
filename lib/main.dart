import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/app_state.dart';
import 'core/theme.dart';
import 'features/auth/auth_screen.dart';
import 'features/discovery/discovery_screen.dart';
import 'features/booking/booking_screen.dart';
import 'features/account/account_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
    ),
  );
  runApp(BarberApp(state: AppState(await SharedPreferences.getInstance())));
}

class BarberApp extends StatelessWidget {
  const BarberApp({super.key, required this.state, this.initialRoute});
  final AppState state;
  final String? initialRoute;
  @override
  Widget build(BuildContext context) => AppScope(
    state: state,
    child: MaterialApp(
      title: 'BarberApp',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: initialRoute ?? (state.signedIn ? '/home' : '/welcome'),
      onGenerateInitialRoutes: (route) => [_route(route)],
      onGenerateRoute: (settings) => _route(settings.name ?? '/welcome'),
    ),
  );
  Route<void> _route(String name) => MaterialPageRoute(
    settings: RouteSettings(name: name),
    builder: (context) => AnnotatedRegion<SystemUiOverlayStyle>(
      value:
          [
            '/welcome',
            '/login',
            '/signup',
            '/home',
            '/map',
            '/map-small',
            '/shop',
            '/shop-reviews',
            '/confirmation',
          ].contains(name)
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: switch (name) {
        '/welcome' => const AuthScreen(),
        '/login' => const AuthScreen(mode: 'login'),
        '/signup' => const AuthScreen(mode: 'signup'),
        '/home' => const HomeScreen(),
        '/search' => const SearchScreen(),
        '/map' => const MapScreen(),
        '/map-small' => const MapScreen(level: 1),
        '/shop' => const MapScreen(level: 2),
        '/shop-reviews' => const MapScreen(level: 3),
        '/reviews' => const ReviewScreen(),
        '/booking' => const BookingScreen(),
        '/calendar' => const BookingScreen(calendar: true),
        '/services' => const BookingScreen(picker: 'services'),
        '/barbers' => const BookingScreen(picker: 'barbers'),
        '/barber' => const BarberScreen(),
        '/confirmation' => const ConfirmationScreen(),
        '/confirmed' => const SuccessScreen(),
        '/reservations' => const ReservationsScreen(),
        '/previous' => const ReservationsScreen(previous: true),
        '/profile' => const ProfileScreen(),
        '/edit-profile' => const EditAccountScreen(),
        '/password' => const EditAccountScreen(password: true),
        '/bonuses' => const BonusesScreen(),
        '/promo' => const PromoScreen(),
        '/congratulations' => const SuccessScreen(bonus: true),
        _ => const HomeScreen(),
      },
    ),
  );
}
