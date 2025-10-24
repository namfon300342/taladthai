import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/constants.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/upload_image/presentation/pages/upload_image_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: Constants.appName,
      theme: AppTheme.light(),
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const HomePage(),
        ),
        GetPage(
          name: '/upload-img',
          page: () => const UploadImagePage(),
        ),
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}

