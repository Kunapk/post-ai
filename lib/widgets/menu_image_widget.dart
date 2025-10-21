import 'dart:convert';
import 'package:flutter/material.dart';

/// Widget helper สำหรับแสดงรูปภาพ base64 ที่มาจาก Odoo API
///
/// API ส่ง base64 string มาตรงๆในฟิลด์ image
/// ใช้ Image.memory() เพื่อแสดงภาพ
class MenuImageWidget extends StatelessWidget {
  final String image; // base64 string
  final BoxFit fit;
  final double? width;
  final double? height;

  const MenuImageWidget({
    Key? key,
    required this.image,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ถ้าไม่มีรูป ให้ใช้ placeholder
    if (image.isEmpty) {
      debugPrint('🖼️ MenuImageWidget: Image is empty');
      return _buildPlaceholder();
    }

    return _buildProductImage();
  }

  /// แสดงรูปจาก Base64 string
  /// Note: API sends double-encoded base64 (base64 of base64 of image data)
  Widget _buildProductImage() {
    try {
      // 🧹 Clean up: trim whitespace และ newlines
      var cleanBase64 = image.trim();

      final preview = cleanBase64.length > 50
          ? cleanBase64.substring(0, 50)
          : cleanBase64;
      debugPrint(
        '🖼️ MenuImageWidget: Decoding base64 (length: ${cleanBase64.length})',
      );
      debugPrint('   Preview: $preview...');

      // ✅ Fix base64 padding
      cleanBase64 = _fixBase64Padding(cleanBase64);

      // 🔄 FIRST DECODE: Get inner base64 string
      debugPrint('   🔄 First decode: base64 → base64');
      final firstDecode = base64Decode(cleanBase64);
      final innerBase64 = String.fromCharCodes(firstDecode);
      debugPrint(
        '   ✅ First decode done! Inner base64 length: ${innerBase64.length}',
      );

      // ✅ Fix padding for inner base64
      var innerBase64Fixed = _fixBase64Padding(innerBase64);

      // � SECOND DECODE: Get actual image bytes
      debugPrint('   🔄 Second decode: base64 → image bytes');
      final imageBytes = base64Decode(innerBase64Fixed);
      debugPrint('   ✅ Second decode done! Image bytes: ${imageBytes.length}');

      // 🔍 Check magic bytes - ดูว่าเป็น PNG/JPG ไหม
      _debugMagicBytes(imageBytes);

      return Image.memory(
        imageBytes,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('   ❌ Image.memory error: $error');
          return _buildPlaceholder();
        },
      );
    } catch (e) {
      debugPrint('   ❌ Error decoding base64: $e');
      return _buildPlaceholder();
    }
  }

  /// Fix base64 padding - add '=' if needed
  String _fixBase64Padding(String base64String) {
    // Remove any whitespace
    base64String = base64String.replaceAll(RegExp(r'\s'), '');

    // Add padding if needed (base64 length must be multiple of 4)
    final remainder = base64String.length % 4;
    if (remainder != 0) {
      base64String += '=' * (4 - remainder);
      debugPrint('   🔧 Added padding (remainder: $remainder)');
    }

    return base64String;
  }

  /// Check magic bytes ดูว่าเป็นไฟล์ประเภทไหน
  void _debugMagicBytes(List<int> bytes) {
    if (bytes.isEmpty) {
      debugPrint('   ⚠️ Image bytes is empty!');
      return;
    }

    // PNG: 89 50 4E 47
    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      debugPrint('   📸 Magic bytes: PNG detected ✓');
      return;
    }

    // JPG: FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      debugPrint('   📸 Magic bytes: JPG detected ✓');
      return;
    }

    // GIF: 47 49 46
    if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) {
      debugPrint('   📸 Magic bytes: GIF detected ✓');
      return;
    }

    // WebP: 52 49 46 46 ... 57 45 42 50
    if (bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46) {
      if (bytes.length > 11 &&
          bytes[8] == 0x57 &&
          bytes[9] == 0x45 &&
          bytes[10] == 0x42 &&
          bytes[11] == 0x50) {
        debugPrint('   📸 Magic bytes: WebP detected ✓');
        return;
      }
    }

    // ❌ Unknown format
    final firstBytes = bytes
        .take(16)
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join(' ');
    debugPrint('   ⚠️ Unknown format! First 16 bytes: $firstBytes');
    debugPrint(
      '   💡 May not be an image file - could be encoded metadata or path',
    );
  }

  /// แสดง Placeholder เมื่อไม่มีรูป
  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey[400],
        size: 40,
      ),
    );
  }
}
