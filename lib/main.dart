import 'package:brainboosters_app/ui/navigation/app_router.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:media_kit/media_kit.dart';                      // Provides [Player], [Media], [Playlist] etc.

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://ipnhjkbgxlhjptviiqcq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlwbmhqa2JneGxoanB0dmlpcWNxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk3MTYwMDUsImV4cCI6MjA2NTI5MjAwNX0.71kriJWMSZkoqRlK4fVfoO88coDnAUrx97nvEe-M3Ws',
  );
  MediaKit.ensureInitialized();
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      localizationsDelegates: const [
        FlutterQuillLocalizations.delegate,
      ],
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF4AA0E6), // Primary Blue
        scaffoldBackgroundColor: const Color(0xFFF9FBFD), // Slightly off-white
        canvasColor: const Color(0xFFE6F4FB), // Light Blue, sidebar/footer
        cardColor: Colors.white, // Card/Section White
        dividerColor: const Color(0xFFE9EDF2), // Divider Grey
        iconTheme: const IconThemeData(
          color: Color(0xFF4AA0E6),
        ), // Primary Blue icons
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Color(0xFF222B45)), // Text Primary
          bodyMedium: TextStyle(color: Color(0xFF6E7A8A)), // Text Secondary
        ),
        colorScheme:
            ColorScheme.fromSwatch(
              primarySwatch: MaterialColor(0xFF4AA0E6, <int, Color>{
                50: Color(0xFFE6F4FB),
                100: Color(0xFFB3DDF3),
                200: Color(0xFF80C7EB),
                300: Color(0xFF4AA0E6),
                400: Color(0xFF3392DF),
                500: Color(0xFF1C85D8),
                600: Color(0xFF1878C2),
                700: Color(0xFF146AAD),
                800: Color(0xFF105C97),
                900: Color(0xFF0C4E82),
              }),
              accentColor: const Color(0xFF49D49D), // Sidebar Icon Green
              backgroundColor: const Color(0xFFE6F4FB), // Footer Blue
            ).copyWith(
              secondary: const Color(0xFF49D49D), // For accent widgets
            ),
        switchTheme: SwitchThemeData(
          trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((
            Set<WidgetState> states,
          ) {
            if (!states.contains(WidgetState.selected)) {
              return Colors.grey[400]; // Outline color when off
            }
            return null; // No outline when on
          }),
          thumbColor: WidgetStateProperty.resolveWith<Color?>((
            Set<WidgetState> states,
          ) {
            if (!states.contains(WidgetState.selected)) {
              return Colors.grey[400]; // Outline color when off
            }
            return null; // No outline when on
          }),
          trackOutlineWidth: WidgetStateProperty.resolveWith<double?>((
            Set<WidgetState> states,
          ) {
            if (!states.contains(WidgetState.selected)) {
              return 1.5; // Outline width when off
            }
            return null; // No outline when on
          }),
        ),
      ),
    );
  }
}
