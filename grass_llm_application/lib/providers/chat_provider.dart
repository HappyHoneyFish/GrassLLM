// 文件路径: lib/providers/chat_provider.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:image_picker/image_picker.dart';
import '../data/models.dart';
import '../data/network/baidu_voice_service.dart';
import '../data/network/api_client.dart';
import '../logic/prompt_builder.dart';
import '../core/utils.dart';
import 'user_provider.dart';
import 'timeline_provider.dart';

/// 语音问答与多模态交互状态管理
class ChatProvider with ChangeNotifier {
  // --- 状态变量 ---
  List<ChatMessage> _messages = []; // 对话历史流
  bool _isRecording = false; // 是否正在录音
  bool _isLoading = false; // 是否正在等待大模型回复
  String? _currentImagePath; // 当前准备发送的图片路径

  final AudioRecorder _audioRecorder = AudioRecorder();
  final ImagePicker _imagePicker = ImagePicker();

  // --- Getters ---
  List<ChatMessage> get messages => _messages;
  bool get isRecording => _isRecording;
  bool get isLoading => _isLoading;
  String? get currentImagePath => _currentImagePath;

  // ==========================================
  // 1. 拍照功能 (唤起系统相机)
  // ==========================================
  Future<void> takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80, // 压缩一下图片质量，加快网络传输
        maxWidth: 1080,
      );
      if (photo != null) {
        _currentImagePath = photo.path;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("拍照异常: $e");
    }
  }

  // ==========================================
  // 2. 清除当前选中的照片
  // ==========================================
  void clearImage() {
    _currentImagePath = null;
    notifyListeners();
  }

  // ==========================================
  // 3. 开始录音
  // ==========================================
  Future<bool> startRecording(BuildContext context) async {
    // 请求麦克风权限
    print("👉 尝试获取麦克风权限...");
    final hasPermission = await AppUtils.requestMediaPermissions();
    print("👉 权限获取结果: $hasPermission");
    if (!hasPermission) {
      if (context.mounted) AppUtils.showToast(context, "请在设置中授予麦克风和相机权限", isError: true);
      return false;
    }

    try {
      // 1. 后缀改为 .wav
      final path = '${Directory.systemTemp.path}/grassland_query.wav';

      // 2. 编码改为 pcm16bits，并且强制单声道 (numChannels: 1)，这是百度要求的标准格式
      await _audioRecorder.start(
          const RecordConfig(
              encoder: AudioEncoder.pcm16bits,
              sampleRate: 16000,
              numChannels: 1
          ),
          path: path
      );
      _isRecording = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("录音启动失败: $e");
      return false;
    }
  }

  // ==========================================
  // 4. 结束录音，自动识别并提交给大模型
  // ==========================================
  Future<void> stopRecordingAndSubmit(
      BuildContext context,
      UserProvider userProvider,
      TimelineProvider timelineProvider
      ) async {
    if (!_isRecording) return;

    try {
      final path = await _audioRecorder.stop();
      _isRecording = false;
      notifyListeners();

      if (path != null) {
        _isLoading = true;
        notifyListeners();

        // a. 调用百度短语音接口，将音频转为文本
        final recognizedText = await BaiduVoiceService.recognizeSpeech(path, format: 'wav');

        if (recognizedText != null && recognizedText.isNotEmpty) {
          // 拿到文字了，带着图片一起提交给大模型
          await _submitToAgent(recognizedText, userProvider, timelineProvider);
        } else {
          if (context.mounted) AppUtils.showToast(context, "未能听清您的话，请再试一次", isError: true);
          _isLoading = false;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("处理录音和请求失败: $e");
      _isRecording = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // 5. 将文本+图片交由大模型处理的内部私有方法
  // ==========================================
  Future<void> _submitToAgent(
      String question,
      UserProvider userProvider,
      TimelineProvider timelineProvider
      ) async {
    // 1. 将用户的提问上屏展示
    _messages.add(ChatMessage(
      text: question,
      isUser: true,
      imagePath: _currentImagePath,
    ));
    notifyListeners();

    // 2. 组装神级 Prompt
    final profile = userProvider.profile ?? UserProfile(hasPlanted: false);

    // 从 timeline 提取当前的天气（如果有的话）
    String weatherContext = "";
    final currentEvent = timelineProvider.events.firstWhere(
            (e) => e.status == EventStatus.current,
        orElse: () => TimelineEvent(title: "", description: "", status: EventStatus.past)
    );
    if (currentEvent.dynamicTip != null && currentEvent.dynamicTip!.contains("气象")) {
      weatherContext = currentEvent.dynamicTip!;
    }

    final finalPrompt = PromptBuilder.buildExpertPrompt(
      profile: profile,
      weatherInfo: weatherContext,
      userQuestion: question,
    );

    // 3. 向后端司农大模型发起网络请求
    final answer = await ApiClient.askAgent(finalPrompt, imagePath: _currentImagePath);

    // 4. 清理当前图片挂载状态
    _currentImagePath = null;

    // 5. 将大模型的回答上屏展示
    if (answer != null) {
      _messages.add(ChatMessage(text: answer, isUser: false));
    } else {
      _messages.add(ChatMessage(text: "网络不佳或模型开小差了，请稍后再试。", isUser: false));
    }

    _isLoading = false;
    notifyListeners();
  }
}