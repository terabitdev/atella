import 'package:flutter/material.dart';

class TextInputWithSend extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final VoidCallback onSend;
  final bool isLoading;

  const TextInputWithSend({
    super.key,
    required this.controller,
    required this.placeholder,
    required this.onSend,
    this.isLoading = false,
  }) ;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(236, 239, 246, 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: placeholder,
                  hintStyle: const TextStyle(color: Colors.black, fontSize: 16),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () => controller.clear(),
                  ),
                ),
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: onSend,
            child: isLoading
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : Image.asset('assets/images/send.png', width: 48, height: 48),
          ),
        ],
      ),
    );
  }
}
