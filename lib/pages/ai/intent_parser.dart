import 'dart:convert';

class IntentParser {
  final List<Map<String, dynamic>> menuItems;

  IntentParser(this.menuItems);

  /// แยกสิ่งที่ต้อง 'เพิ่ม' และ 'ลบ' ออกจากคำพูด AI (improved for no-space patterns)
  Map<String, List<Map<String, dynamic>>> parse(String input) {
    final lowered = input.toLowerCase();
    final result = {
      'add': <Map<String, dynamic>>[],
      'remove': <Map<String, dynamic>>[],
      'confirm': <Map<String, dynamic>>[],
      'update': <Map<String, dynamic>>[],
    };

    final addKeywords = ['เพิ่ม', 'สั่ง', 'ซื้อ', 'เอา', 'หยิบ', 'ขอ'];
    final removeKeywords = ['ลบ', 'เอาออก', 'ยกเลิก'];
    final updateKeywords = ['ขอเป็น', 'เปลี่ยนเป็น', 'เอาเป็น', 'เอาเพิ่มเป็น'];

    for (final item in menuItems) {
      // Collect all names and aliases
      final names = [item['name'].toString().toLowerCase()];
      if (item.containsKey('alias')) {
        names.addAll(
          (item['alias'] as List).map((e) => e.toString().toLowerCase()),
        );
      }

      bool alreadyMatched = false;

      // 🟡 Handle update intent first (allowing both name-before-keyword and keyword-before-name)
      for (final word in updateKeywords) {
        for (final name in names) {
          // Pattern 1: name before keyword (e.g., "ชานมไข่มุกเปลี่ยนเป็น 3")
          final pattern1 = RegExp("${RegExp.escape(name)}.*?$word\\D*(\\d+)?");
          // Pattern 2: keyword before name (e.g., "เปลี่ยนชานมไข่มุกเป็น 3")
          final pattern2 = RegExp(
            "$word\\s*${RegExp.escape(name)}(?:\\D*(\\d+))?",
          );
          final match1 = pattern1.firstMatch(lowered);
          final match2 = pattern2.firstMatch(lowered);
          final match = match1 ?? match2;
          if (match != null) {
            // group(1) is the qty for both patterns
            final qty = int.tryParse(match.group(1) ?? '') ?? 1;
            result['update']!.add({...item, 'qty': qty});
            alreadyMatched = true;
            break;
          }
        }
        if (alreadyMatched) break;
      }

      // 🟢 Then add
      if (!alreadyMatched) {
        for (final word in addKeywords) {
          for (final name in names) {
            final pattern = RegExp(
              "$word\\s*${RegExp.escape(name)}(?:\\D*(\\d+))?",
            );
            final match = pattern.firstMatch(lowered);
            if (match != null) {
              final qty = int.tryParse(match.group(1) ?? '') ?? 1;
              result['add']!.add({...item, 'qty': qty});
              alreadyMatched = true;
              break;
            }
          }
          if (alreadyMatched) break;
        }
      }

      // 🔴 Always allow remove matching
      for (final word in removeKeywords) {
        for (final name in names) {
          final pattern = RegExp("$word\\s*${RegExp.escape(name)}\\s*(\\d+)?");
          final match = pattern.firstMatch(lowered);
          if (match != null) {
            final qty = int.tryParse(match.group(1) ?? '') ?? 1;
            result['remove']!.add({...item, 'qty': qty});
            break;
          }
        }
      }

      // 🟣 Fallback to add if nothing matched
      if (!alreadyMatched) {
        for (final name in names) {
          final fallbackPattern = RegExp("(${RegExp.escape(name)})\\D*(\\d+)?");
          final match = fallbackPattern.firstMatch(lowered);
          if (match != null) {
            final qty = int.tryParse(match.group(2) ?? '') ?? 1;
            result['add']!.add({...item, 'qty': qty});
            break;
          }
        }
      }
    }

    // Add confirm fallback if no add/remove found but a product is mentioned
    if (result['add']!.isEmpty && result['remove']!.isEmpty) {
      for (final item in menuItems) {
        final names = [item['name'].toString().toLowerCase()];
        if (item.containsKey('alias')) {
          names.addAll(
            (item['alias'] as List).map((e) => e.toString().toLowerCase()),
          );
        }
        for (final name in names) {
          if (lowered.contains(name)) {
            result['confirm']!.add({...item, 'qty': 1});
            break;
          }
        }
        if (result['confirm']!.isNotEmpty) break;
      }
    }

    return result;
  }
}

// Example menuItems definition for context:
final List<Map<String, dynamic>> menuItems = [
  {
    'name': 'ชานมไข่มุก',
    'price': 25,
    'alias': ['ชานมมุก', 'ชาไข่มุก', 'ไข่มุก'],
  },
  // ... other menu items
];

// Helper for formatting parsedIntent as JSON for Gemini prompt.
String formatParsedIntentPrompt(Map<String, dynamic> parsedIntent) {
  return '📝 Parsed intent: ${jsonEncode(parsedIntent)}';
}
