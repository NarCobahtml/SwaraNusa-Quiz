import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:swaranusaquiz/app/app.dart';
import 'package:swaranusaquiz/app/data/providers/supabase_config.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';
import 'package:swaranusaquiz/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SupabaseConfig.initialize();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    final full = details.toString(); // includes stack
    return Material(
      color: AppColors.error,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Text(
            full,
            style: const TextStyle(color: AppColors.gold, fontSize: 12),
          ),
        ),
      ),
    );
  };

  runZonedGuarded(
    () {
      runApp(const SwaraNusaQuizApp());
    },
    (error, stack) {
      // ignore: avoid_print
      print('Uncaught zone error:');
      // ignore: avoid_print
      print(error);
      // ignore: avoid_print
      print(stack);
    },
  );
}
