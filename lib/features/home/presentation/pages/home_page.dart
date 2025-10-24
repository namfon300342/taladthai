import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/constants.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(Constants.appName)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('ยินดีต้อนรับสู่หน้าแรกกกกกก'),
            const SizedBox(height: 12),
            const Text('30ปี ตลาดไท'),
            ElevatedButton(
              onPressed: () => Get.toNamed('/upload-img'),
              child: const Text('อัปโหลดรูปภาพ'),
            ),
          ],
        ),
      ),
    );
  }
}
