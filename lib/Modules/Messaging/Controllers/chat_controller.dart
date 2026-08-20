import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:atella/Data/Models/conversation_model.dart';
import 'package:atella/Data/Models/message_model.dart';
import 'package:atella/services/firebase/services/messaging_service.dart';

class ChatController extends GetxController {
  final MessagingService _service = MessagingService();
  final ImagePicker _picker = ImagePicker();

  final Rxn<ConversationModel> conversation = Rxn<ConversationModel>();
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSending = false.obs;
  final RxBool isUploading = false.obs;
  final textController = TextEditingController();

  late final String conversationId;
  StreamSubscription<List<MessageModel>>? _subscription;

  String get currentUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    conversationId = (args is Map && args['conversationId'] is String) ? args['conversationId'] as String : '';

    if (conversationId.isEmpty) {
      isLoading.value = false;
      return;
    }

    _load();
  }

  Future<void> _load() async {
    conversation.value = await _service.getConversation(conversationId);
    isLoading.value = false;

    _subscription = _service.streamMessages(conversationId).listen((list) {
      messages.assignAll(list);
    });

    await _service.markConversationRead(conversationId);
  }

  Future<void> send() async {
    final text = textController.text;
    if (text.trim().isEmpty) return;
    textController.clear();

    isSending.value = true;
    try {
      await _service.sendMessage(conversationId, text);
    } finally {
      isSending.value = false;
    }
  }

  Future<void> pickAndSendImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;
    await _uploadAndSend(File(picked.path), 'image');
  }

  Future<void> pickAndSendDocument() async {
    final result = await FilePicker.platform.pickFiles();
    final path = result?.files.single.path;
    if (path == null) return;
    await _uploadAndSend(File(path), 'file');
  }

  Future<void> _uploadAndSend(File file, String type) async {
    isUploading.value = true;
    try {
      await _service.sendAttachmentMessage(
        conversationId,
        file: file,
        type: type,
        fileName: file.uri.pathSegments.last,
      );
    } finally {
      isUploading.value = false;
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    textController.dispose();
    super.onClose();
  }
}
