import 'package:flutter/material.dart';

class FloatingAIButtonMobile extends StatelessWidget {
  final VoidCallback onPressed;
  final String? lastMessage; // ✅ ข้อความล่าสุดจาก AI

  const FloatingAIButtonMobile({
    super.key,
    required this.onPressed,
    this.lastMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // === Bubble แสดงข้อความ AI ===
          if (lastMessage != null && lastMessage!.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxWidth: 220),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Text(
                lastMessage!,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),

          // === ปุ่ม AI ===
          FloatingActionButton(
            backgroundColor: Colors.deepPurple,
            onPressed: onPressed,
            child: const Icon(Icons.mic, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}
