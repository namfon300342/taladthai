import 'package:flutter/material.dart';
import '../../../../core/utils/constants.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Constants.appName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('ยินดีต้อนรับสู่หน้าแรกกกกกก'),
            SizedBox(height: 12),
            Text('30ปี ตลาดไท'),
          ],
        ),
      ),
    );
  }
}
