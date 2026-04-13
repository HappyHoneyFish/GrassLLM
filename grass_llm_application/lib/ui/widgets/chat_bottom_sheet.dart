// 文件路径: lib/ui/widgets/chat_bottom_sheet.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../providers/chat_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/timeline_provider.dart';
import '../../data/models.dart';

class ChatBottomSheet extends StatefulWidget {
  const ChatBottomSheet({super.key});

  @override
  State<ChatBottomSheet> createState() => _ChatBottomSheetState();
}

class _ChatBottomSheetState extends State<ChatBottomSheet> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 监听到新消息时，自动滚动到最底部
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final userProvider = context.read<UserProvider>();
    final timelineProvider = context.read<TimelineProvider>();

    // 每次构建检查是否需要滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    // 让弹窗高度占据屏幕的 85%
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: const BoxDecoration(
        color: AppConstants.backgroundColor, // 使用全局底色
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // 1. 顶部拖拽指示器与标题
          _buildHeader(context),

          // 2. 聊天消息流
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: chatProvider.messages.length + (chatProvider.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                // 如果正在加载且是最后一项，显示"AI思考中"组件
                if (chatProvider.isLoading && index == chatProvider.messages.length) {
                  return _buildLoadingBubble();
                }
                final message = chatProvider.messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // 3. 当前挂载的照片预览 (如果有)
          if (chatProvider.currentImagePath != null)
            _buildImagePreview(chatProvider),

          // 4. 底部多模态交互操作区 (拍照 + 按住说话)
          _buildInputArea(context, chatProvider, userProvider, timelineProvider),
        ],
      ),
    );
  }

  // ==========================================
  // 子组件：头部指示器
  // ==========================================
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "草业智能诊断",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.textMainColor),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 子组件：照片预览区域
  // ==========================================
  Widget _buildImagePreview(ChatProvider chatProvider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(chatProvider.currentImagePath!),
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            right: -8,
            top: -8,
            child: GestureDetector(
              onTap: chatProvider.clearImage,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 子组件：底部操作区 (按住说话)
  // ==========================================
  Widget _buildInputArea(
      BuildContext context,
      ChatProvider chatProvider,
      UserProvider userProvider,
      TimelineProvider timelineProvider) {
    return Container(
      padding: EdgeInsets.only(
          left: 16, right: 16, top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))
        ],
      ),
      child: Row(
        children: [
          // 拍照按钮
          IconButton(
            onPressed: chatProvider.isLoading ? null : chatProvider.takePhoto,
            icon: Icon(Icons.camera_alt_outlined, color: chatProvider.isLoading ? Colors.grey : AppConstants.textSecondaryColor, size: 28),
          ),
          const SizedBox(width: 8),

          // 按住说话按钮 (核心交互)
          Expanded(
            child: GestureDetector(
              onLongPressDown: (_) async {
                if (!chatProvider.isLoading) {
                  await chatProvider.startRecording(context);
                }
              },
              onLongPressUp: () async {
                if (chatProvider.isRecording) {
                  await chatProvider.stopRecordingAndSubmit(context, userProvider, timelineProvider);
                }
              },
              onLongPressCancel: () async {
                if (chatProvider.isRecording) {
                  await chatProvider.stopRecordingAndSubmit(context, userProvider, timelineProvider);
                }
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: chatProvider.isRecording ? AppConstants.primaryColor : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: chatProvider.isRecording ? AppConstants.primaryColor : Colors.grey.shade300),
                ),
                alignment: Alignment.center,
                child: Text(
                  chatProvider.isRecording ? "松开 发送" : "按住 说话",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: chatProvider.isRecording ? Colors.white : AppConstants.textMainColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 子组件：聊天气泡
  // ==========================================
  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI 头像
          if (!message.isUser) ...[
            const CircleAvatar(
              backgroundColor: AppConstants.primaryLightColor,
              child: Icon(Icons.eco, color: AppConstants.primaryColor, size: 20),
            ),
            const SizedBox(width: 8),
          ],

          // 气泡主体
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? AppConstants.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(16).copyWith(
                  topLeft: message.isUser ? const Radius.circular(16) : const Radius.circular(4),
                  topRight: message.isUser ? const Radius.circular(4) : const Radius.circular(16),
                ),
                border: message.isUser ? null : Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 如果带有照片，先显示照片
                  if (message.imagePath != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(message.imagePath!),
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  // 文本内容
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 15,
                      color: message.isUser ? Colors.white : AppConstants.textMainColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 占位，确保气泡不过长
          if (message.isUser) const SizedBox(width: 48) else const SizedBox(width: 48),
        ],
      ),
    );
  }

  // ==========================================
  // 子组件：AI 思考中
  // ==========================================
  Widget _buildLoadingBubble() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          backgroundColor: AppConstants.primaryLightColor,
          child: Icon(Icons.eco, color: AppConstants.primaryColor, size: 20),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16).copyWith(topLeft: const Radius.circular(4)),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppConstants.primaryColor),
              ),
              SizedBox(width: 10),
              Text("司农大模型推演中...", style: TextStyle(color: AppConstants.textSecondaryColor, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}