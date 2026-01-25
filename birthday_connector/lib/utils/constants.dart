import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

const kProfilesTable = 'user_profiles';

const kUserIdCol = 'id';
const kUsernameCol = 'username';
const kEmailCol = 'email';
const kBirthDateCol = 'birth_date';

final appTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: const Color.fromARGB(255, 21, 65, 122),
  ),
  textTheme: GoogleFonts.latoTextTheme(),
);
