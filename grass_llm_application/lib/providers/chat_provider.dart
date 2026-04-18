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

  List<ChatMessage> _messages = [];
  bool _isRecording = false;
  bool _isLoading = false;
  String? _currentImagePath;

  final AudioRecorder _audioRecorder = AudioRecorder();
  final ImagePicker _imagePicker = ImagePicker();

  List<ChatMessage> get messages => _messages;
  bool get isRecording => _isRecording;
  bool get isLoading => _isLoading;
  String? get currentImagePath => _currentImagePath;


  Future<void> takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
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


  void clearImage() {
    _currentImagePath = null;
    notifyListeners();
  }


  Future<bool> startRecording(BuildContext context) async {
    print("👉 尝试获取麦克风权限...");
    final hasPermission = await AppUtils.requestMediaPermissions();
    print("👉 权限获取结果: $hasPermission");
    if (!hasPermission) {
      if (context.mounted) AppUtils.showToast(context, "请在设置中授予麦克风和相机权限", isError: true);
      return false;
    }

    try {
      final path = '${Directory.systemTemp.path}/grassland_query.wav';

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

        final recognizedText = await BaiduVoiceService.recognizeSpeech(path, format: 'wav');

        if (recognizedText != null && recognizedText.isNotEmpty) {

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

  Future<void> _submitToAgent(
      String question,
      UserProvider userProvider,
      TimelineProvider timelineProvider
      ) async {

    _messages.add(ChatMessage(
      text: question,
      isUser: true,
      imagePath: _currentImagePath,
    ));
    notifyListeners();


    final profile = userProvider.profile ?? UserProfile(hasPlanted: false);


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

    final answer = await ApiClient.askAgent(finalPrompt, imagePath: _currentImagePath);

    _currentImagePath = null;

    if (answer != null) {
      _messages.add(ChatMessage(text: answer, isUser: false));
    } else {
      _messages.add(ChatMessage(text: "网络不佳或模型开小差了，请稍后再试。", isUser: false));
    }

    _isLoading = false;
    notifyListeners();
  }
}