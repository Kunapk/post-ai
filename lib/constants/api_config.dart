/// API Configuration - แก้จุดเดียวสำหรับทั้ง HTTP/HTTPS
class ApiConfig {
  /// ตั้ง true สำหรับ production (HTTPS), false สำหรับ development (HTTP)
  static const bool useHttps = false;

  /// Base URL ของ API (ไม่รวม protocol)
  static const String baseUrl = 'localhost:8071';

  /// API Version
  static const String apiVersion = 'api/v1';

  /// สร้าง Uri.http หรือ Uri.https ตามการตั้งค่า
  /// Path ต้องขึ้นต้นด้วย / เสมอ
  static Uri buildUri(String path) {
    // ทำให้แน่ใจว่า path ขึ้นต้นด้วย /
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    if (useHttps) {
      return Uri.https(baseUrl, normalizedPath);
    } else {
      return Uri.http(baseUrl, normalizedPath);
    }
  }

  /// สร้าง Full URL string (สำหรับ debug หรือการแสดงข้อมูล)
  static String getFullUrl(String path) {
    final protocol = useHttps ? 'https' : 'http';
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$protocol://$baseUrl$normalizedPath';
  }
}
