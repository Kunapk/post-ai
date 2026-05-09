/// API Configuration - แก้จุดเดียวสำหรับทั้ง HTTP/HTTPS
class ApiConfig {
  /// ตั้ง true สำหรับ production (HTTPS), false สำหรับ development (HTTP)
  // static const bool useHttps = true;
  static const bool useHttps = false;

  /// Base URL ของ API (ไม่รวม protocol)
  // static const String baseUrl = '192.168.50.237:8071';
  static const String baseUrl = 'localhost:8071';
  // static const String baseUrl = 'smartpos.safebsc.finance';

  /// API Version
  static const String apiVersion = 'api/v1';

  /// สร้าง Uri.http หรือ Uri.https ตามการตั้งค่า
  /// Path ต้องขึ้นต้นด้วย / เสมอ
  static Uri buildUri(String path) {
    // ทำให้แน่ใจว่า path ขึ้นต้นด้วย /
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    // 🔧 Fix: Use Uri.parse instead of Uri.http to avoid encoding issues
    final protocol = useHttps ? 'https' : 'http';
    final fullUrl = '$protocol://$baseUrl$normalizedPath';

    return Uri.parse(fullUrl);
  }

  /// สร้าง Full URL string (สำหรับ debug หรือการแสดงข้อมูล)
  static String getFullUrl(String path) {
    final protocol = useHttps ? 'https' : 'http';
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$protocol://$baseUrl$normalizedPath';
  }
}
