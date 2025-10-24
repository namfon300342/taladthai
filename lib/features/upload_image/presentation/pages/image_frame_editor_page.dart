import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui' as ui;
import 'package:universal_html/html.dart' as html;

class ImageFrameEditorPage extends StatefulWidget {
  final Uint8List imageBytes;
  final String imageName;

  const ImageFrameEditorPage({
    super.key,
    required this.imageBytes,
    required this.imageName,
  });

  @override
  State<ImageFrameEditorPage> createState() => _ImageFrameEditorPageState();
}

class _ImageFrameEditorPageState extends State<ImageFrameEditorPage> {
  final ImagePicker _picker = ImagePicker();
  final GlobalKey _repaintKey = GlobalKey();

  int _selectedFrameIndex = 0;
  late Uint8List _currentImageBytes;

  @override
  void initState() {
    super.initState();
    _currentImageBytes = widget.imageBytes;
  }

  Future<void> _pickNewImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2000,
        maxHeight: 2000,
      );

      if (image != null) {
        final Uint8List imageBytes = await image.readAsBytes();
        setState(() {
          _currentImageBytes = imageBytes;
        });
      }
    } catch (e) {
      Get.snackbar(
        'เกิดข้อผิดพลาด',
        'ไม่สามารถเลือกรูปภาพได้ กรุณาลองใหม่อีกครั้ง',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  Future<void> _downloadImage() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
      );

      RenderRepaintBoundary boundary =
          _repaintKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final blob = html.Blob([pngBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement()
        ..href = url
        ..style.display = 'none'
        ..download =
            'taladthai_30th_${DateTime.now().millisecondsSinceEpoch}.png';

      html.document.body?.children.add(anchor);
      anchor.click();

      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);

      Get.back();

      Get.snackbar(
        'สำเร็จ',
        'ดาวน์โหลดรูปภาพเรียบร้อยแล้ว',
        backgroundColor: const Color(0xFF00A651).withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        'เกิดข้อผิดพลาด',
        'ไม่สามารถดาวน์โหลดรูปภาพได้ กรุณาลองใหม่อีกครั้ง',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  Future<void> _shareImage() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
      );

      RenderRepaintBoundary boundary =
          _repaintKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      Get.back();

      _showShareOptionsDialog(pngBytes);
    } catch (e) {
      Get.back();
      Get.snackbar(
        'เกิดข้อผิดพลาด',
        'ไม่สามารถแชร์รูปภาพได้ กรุณาลองใหม่อีกครั้ง',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  void _showShareOptionsDialog(Uint8List imageBytes) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF06763B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFD700), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'แชร์รูปภาพไปที่',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareOption(
                    icon: Icons.facebook,
                    label: 'Facebook',
                    color: const Color(0xFF1877F2),
                    onTap: () {
                      Get.back();
                      _shareToFacebook(imageBytes);
                    },
                  ),

                  _buildShareOption(
                    icon: Icons.camera_alt,
                    label: 'Instagram',
                    color: const Color(0xFFE4405F),
                    onTap: () {
                      Get.back();
                      _shareToInstagram(imageBytes);
                    },
                  ),

                  _buildShareOption(
                    icon: Icons.share,
                    label: 'อื่นๆ',
                    color: const Color(0xFF00A651),
                    onTap: () {
                      Get.back();
                      _shareToOthers(imageBytes);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'ยกเลิก',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _shareToFacebook(Uint8List imageBytes) {
    final blob = html.Blob([imageBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement()
      ..href = url
      ..style.display = 'none'
      ..download = 'taladthai_30th.png';

    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);

    Get.snackbar(
      'แจ้งเตือน',
      'กรุณาอัปโหลดรูปที่ดาวน์โหลดไปยัง Facebook',
      backgroundColor: const Color(0xFF1877F2).withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );

    html.window.open('https://www.facebook.com/', '_blank');
  }

  void _shareToInstagram(Uint8List imageBytes) {
    final blob = html.Blob([imageBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement()
      ..href = url
      ..style.display = 'none'
      ..download = 'taladthai_30th.png';

    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);

    Get.snackbar(
      'แจ้งเตือน',
      'กรุณาอัปโหลดรูปที่ดาวน์โหลดไปยัง Instagram',
      backgroundColor: const Color(0xFFE4405F).withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );

    html.window.open('https://www.instagram.com/', '_blank');
  }

  void _shareToOthers(Uint8List imageBytes) {
    final blob = html.Blob([imageBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement()
      ..href = url
      ..style.display = 'none'
      ..download = 'taladthai_30th.png';

    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);

    Get.snackbar(
      'สำเร็จ',
      'ดาวน์โหลดรูปภาพเรียบร้อย สามารถแชร์ต่อได้',
      backgroundColor: const Color(0xFF00A651).withOpacity(0.8),
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF06763B), Color(0xFF04562B)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildAwningDecoration(),

                const SizedBox(height: 20),

                _buildLogoSection(),

                const SizedBox(height: 16),

                const Text(
                  'อัปโหลดรูปภาพ พร้อมกรอบรูปที่ชอบได้เลย!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                _buildImagePreview(),

                const SizedBox(height: 16),

                _buildUploadNewButton(),

                const SizedBox(height: 20),

                _buildFrameSelector(),

                const SizedBox(height: 20),

                _buildActionButtons(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAwningDecoration() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF00A651),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: List.generate(5, (index) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: index.isEven ? Colors.white : const Color(0xFF00A651),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '30',
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2
                  ..color = const Color(0xFFFFD700),
              ),
            ),
            Text(
              '30',
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFFD700).withOpacity(0.8),
              ),
            ),
            Positioned(
              bottom: 0,
              right: -10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'th',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                  Text(
                    'ANNIVERSARY',
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'ตลาดไท',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF06763B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return RepaintBoundary(
      key: _repaintKey,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),

              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(_currentImageBytes, fit: BoxFit.cover),
              ),

              _buildFrameOverlay(_selectedFrameIndex),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrameOverlay(int frameIndex) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getFrameColor(frameIndex),
          width: _getFrameWidth(frameIndex),
        ),
      ),
      child: CustomPaint(
        painter: FramePainter(
          frameIndex: frameIndex,
          color: _getFrameColor(frameIndex),
        ),
      ),
    );
  }

  Color _getFrameColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFF00A651);
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return Colors.white;
      default:
        return const Color(0xFF00A651);
    }
  }

  double _getFrameWidth(int index) {
    switch (index) {
      case 0:
        return 8;
      case 1:
        return 12;
      case 2:
        return 6;
      default:
        return 8;
    }
  }

  Widget _buildUploadNewButton() {
    return TextButton.icon(
      onPressed: _pickNewImage,
      icon: const Icon(Icons.refresh, color: Colors.white),
      label: const Text(
        'อัปโหลดภาพใหม่',
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  Widget _buildFrameSelector() {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(3, (index) {
          final isSelected = _selectedFrameIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFrameIndex = index;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFFFD700)
                        : Colors.white.withOpacity(0.3),
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        width: 60,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getFrameColor(index),
                            width: 4,
                          ),
                        ),
                        child: Image.memory(
                          _currentImageBytes,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00A651),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: _shareImage,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.share, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'แชร์',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: _downloadImage,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.download, color: Color(0xFF06763B), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'ดาวน์โหลดรูปภาพ',
                      style: TextStyle(
                        color: Color(0xFF06763B),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FramePainter extends CustomPainter {
  final int frameIndex;
  final Color color;

  FramePainter({required this.frameIndex, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    switch (frameIndex) {
      case 0:
        break;
      case 1:
        final innerRect = Rect.fromLTWH(
          16,
          16,
          size.width - 32,
          size.height - 32,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(innerRect, const Radius.circular(8)),
          paint,
        );
        break;
      case 2:
        _drawDashedBorder(canvas, size, paint);
        break;
    }
  }

  void _drawDashedBorder(Canvas canvas, Size size, Paint paint) {
    const dashWidth = 10.0;
    const dashSpace = 5.0;
    double startX = 16;

    while (startX < size.width - 16) {
      canvas.drawLine(
        Offset(startX, 16),
        Offset(startX + dashWidth, 16),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
