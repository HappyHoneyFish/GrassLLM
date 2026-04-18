// 文件路径: lib/ui/widgets/voice_photo_fab.dart

import 'package:flutter/material.dart';
import '../../core/constants.dart';

class VoicePhotoFab extends StatelessWidget {
  final VoidCallback onOpenChat;

  const VoicePhotoFab({
    super.key,
    required this.onOpenChat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 56,
      decoration: BoxDecoration(
        color: AppConstants.primaryColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.3),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onOpenChat,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mic_none_rounded, color: Colors.white, size: 26),
                const SizedBox(width: 8),
                const Text(
                  "极速问诊",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),

                const SizedBox(width: 16),

                Container(
                  width: 1,
                  height: 20,
                  color: Colors.white.withOpacity(0.4),
                ),

                const SizedBox(width: 16),

                const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}