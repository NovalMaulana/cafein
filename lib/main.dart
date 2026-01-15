import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/login_page.dart';
import 'pages/map_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mcqsrhocyjgdnywivhnm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1jcXNyaG9jeWpnZG55d2l2aG5tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgzODk4ODIsImV4cCI6MjA4Mzk2NTg4Mn0.jQJVWLG9VNnXmSdQ0lz-VmVHEAq6woUTyaIc9N-4G_M',
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
