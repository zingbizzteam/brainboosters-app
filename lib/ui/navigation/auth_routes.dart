// ui/navigation/auth_routes.dart
import 'package:go_router/go_router.dart';
import '../../screens/authentication/auth_selection_page.dart';
import '../../screens/authentication/student/email/email_register_page.dart';
import '../../screens/authentication/student/email/email_login_page.dart';
import '../../screens/authentication/student/email/email_reset_password_page.dart';
import '../../screens/authentication/user_setup/user_setup_page.dart';

class AuthRoutes {
  static const String prefix = '/auth';
  static const String emailRegister = '$prefix/email/register';
  static const String emailLogin = '$prefix/email/login';
  static const String emailResetPassword = '$prefix/email/reset-password';
  static const String facultyLogin = '$prefix/faculty/login';
  static const String coachingCenterLogin = '$prefix/coaching-center/login';
  static const String coachingCenterRegister = '$prefix/coaching-center/register';
  static const String adminLogin = '$prefix/admin/secure-portal'; // Hidden URL
  static const String authSelection = prefix;
  static const String userSetup = '$prefix/user-setup';

  static final routes = [
    GoRoute(
      path: emailRegister,
      builder: (context, state) => const EmailRegisterPage(),
    ),
    GoRoute(
      path: emailLogin,
      builder: (context, state) => const EmailLoginPage(),
    ),
    GoRoute(
      path: emailResetPassword,
      builder: (context, state) => const EmailResetPasswordPage(),
    ),
  
    GoRoute(
      path: authSelection,
      builder: (context, state) => const AuthSelectionPage(),
    ),
    GoRoute(
      path: userSetup,
      builder: (context, state) => const UserSetupPage(),
    ),
  ];
}
