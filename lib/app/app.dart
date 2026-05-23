import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swaranusaquiz/app/routes/app_pages.dart';
import 'package:swaranusaquiz/app/utils/app_theme.dart';

class SwaraNusaQuizApp extends StatelessWidget {
  const SwaraNusaQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Music Learning App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}
