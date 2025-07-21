import 'package:flutter/material.dart';

class TextInputWithSend extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final VoidCallback onSend;
  final bool isLoading;

  const TextInputWithSend({
    Key? key,
    required this.controller,
    required this.placeholder,
    required this.onSend,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: const TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 12),
          // Clear button (X)
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () => controller.clear(),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFCCCCCC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          const SizedBox(width: 8),
          // Send button
          GestureDetector(
            onTap: controller.text.trim().isNotEmpty ? onSend : null,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: controller.text.trim().isNotEmpty
                    ? const LinearGradient(
                        colors: [Color(0xFF8B5FE6), Color(0xFF7B5AC7)],
                      )
                    : null,
                color: controller.text.trim().isEmpty
                    ? const Color(0xFFE0E0E0)
                    : null,
                shape: BoxShape.circle,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      Icons.send_rounded,
                      color: controller.text.trim().isNotEmpty
                          ? Colors.white
                          : const Color(0xFF999999),
                      size: 18,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
