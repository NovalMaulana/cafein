import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/login_page.dart';
import 'pages/map_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://(...).supabase.co',
    anonKey:
        'ey(...)',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          // Check if user is logged in
          final session = snapshot.hasData ? snapshot.data!.session : null;

          if (session != null) {
            // User is logged in, show map page
            return const MapPage();
          } else {
            // User is not logged in, show login page
            return const LoginPage();
          }
        },
      ),
    );
  }
}
