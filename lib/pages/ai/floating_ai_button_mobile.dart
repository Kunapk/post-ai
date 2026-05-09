import 'package:flutter/material.dart';

class FloatingAIButtonMobile extends StatefulWidget {
  final VoidCallback onPressed;
  final String? lastMessage; // ✅ ข้อความล่าสุดจาก AI
  final bool isRecording; // 🎤 แสดงสถานะการบันทึก

  const FloatingAIButtonMobile({
    super.key,
    required this.onPressed,
    this.lastMessage,
    this.isRecording = false,
  });

  @override
  State<FloatingAIButtonMobile> createState() => _FloatingAIButtonMobileState();
}

class _FloatingAIButtonMobileState extends State<FloatingAIButtonMobile>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    // 🎤 Pulsing animation for recording state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Scale animation on press
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(FloatingAIButtonMobile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 🎤 Start/stop pulse animation based on recording state
    if (widget.isRecording && !oldWidget.isRecording) {
      _pulseController.repeat();
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 20, // 👈 Changed from right to left
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // === Bubble แสดงข้อความ AI ===
          if (widget.lastMessage != null && widget.lastMessage!.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxWidth: 240),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                widget.lastMessage!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
                overflow: TextOverflow.fade,
              ),
            ),

          // === AI Button with Modern Design ===
          GestureDetector(
            onTapDown: (_) {
              _scaleController.forward();
            },
            onTapUp: (_) {
              _scaleController.reverse();
              widget.onPressed();
            },
            onTapCancel: () {
              _scaleController.reverse();
            },
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 0.95).animate(
                CurvedAnimation(
                  parent: _scaleController,
                  curve: Curves.easeOut,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 🎤 Pulsing ring effect (only when recording)
                  if (widget.isRecording)
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.red.withOpacity(
                                1.0 - _pulseController.value,
                              ),
                              width: 2,
                            ),
                          ),
                        );
                      },
                    ),

                  // 🎤 Main AI Button
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: widget.isRecording
                            ? [Colors.red, Colors.redAccent]
                            : [
                                const Color(0xFF7C3AED), // Purple
                                const Color(0xFF3B82F6), // Blue
                              ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (widget.isRecording
                                      ? Colors.red
                                      : const Color(0xFF7C3AED))
                                  .withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        widget.isRecording ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),

                  // 🔴 Recording indicator dot
                  if (widget.isRecording)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red.withOpacity(
                                0.5 + (_pulseController.value * 0.5),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
