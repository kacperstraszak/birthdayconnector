import 'package:birthday_connector/utils/constants.dart';
import 'package:birthday_connector/utils/supabase_keys.dart';
import 'package:birthday_connector/widgets/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: kSupabaseUrl,
    anonKey: kAnonKey,
  );
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Birthday Connector',
      theme: appTheme,
      home: const AuthGate(),
    );
  }
}
