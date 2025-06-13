// lib/routes/auth_routes.dart
import 'package:brainboosters_app/screens/dashboard/dashboard_page.dart';
import 'package:go_router/go_router.dart';


class DashboardRoutes  {
  static const String prefix = '/dashboard';
  static const String home = prefix;

  static final routes = [
   GoRoute(
        path: home,
        builder: (context, state) => const DashboardPage(),
   ),
  ];
}
