// 文件路径: lib/data/models.dart

import 'dart:convert';

/// ==========================================
/// 1. 用户档案模型 (UserProfile)
/// ==========================================
class UserProfile {
  final bool hasPlanted; // 是否已经种草 (决定分支 A 或 B)
  final String? location; // 地理位置 (如：甘肃酒泉)
  final String? grassType; // 草种名称 (如：紫花苜蓿)
  final double? area; // 种植面积 (亩)
  final DateTime? plantDate; // 种植日期 (用于计算长了多久)

  UserProfile({
    required this.hasPlanted,
    this.location,
    this.grassType,
    this.area,
    this.plantDate,
  });

  // 获取种植天数
  int get plantedDays {
    if (plantDate == null) return 0;
    return DateTime.now().difference(plantDate!).inDays;
  }

  // 序列化为 Map
  Map<String, dynamic> toMap() {
    return {
      'hasPlanted': hasPlanted,
      'location': location,
      'grassType': grassType,
      'area': area,
      'plantDate': plantDate?.toIso8601String(),
    };
  }

  // 从 Map 反序列化
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      hasPlanted: map['hasPlanted'] ?? false,
      location: map['location'],
      grassType: map['grassType'],
      area: map['area']?.toDouble(),
      plantDate: map['plantDate'] != null ? DateTime.parse(map['plantDate']) : null,
    );
  }

  // JSON 字符串互转 (用于本地 SharedPreferences 存储)
  String toJson() => json.encode(toMap());
  factory UserProfile.fromJson(String source) => UserProfile.fromMap(json.decode(source));
}

/// ==========================================
/// 2. 时间轴节点状态枚举
/// ==========================================
enum EventStatus {
  past,    // 过去已完成
  current, // 当前进行中 (高亮展示)
  future   // 未来预期阶段
}

/// ==========================================
/// 3. 时间轴节点模型 (TimelineEvent)
/// ==========================================
class TimelineEvent {
  final String title; // 阶段标题 (如：选种播种、田间管理、收获收割)
  final String description; // 阶段描述
  final EventStatus status; // 当前状态
  final String? dynamicTip; // 动态提示 (结合天气或本地公式，如"近期干旱，紫花苜蓿需额外浇水")

  TimelineEvent({
    required this.title,
    required this.description,
    required this.status,
    this.dynamicTip,
  });
}

/// ==========================================
/// 4. 对话消息模型 (ChatMessage)
/// ==========================================
class ChatMessage {
  final String text; // 消息文本 (用户语音转成的文本，或大模型返回的文本)
  final bool isUser; // 是否是用户发送的消息
  final String? imagePath; // 用户拍摄的照片本地路径 (如果是图文问答)
  final DateTime timestamp; // 消息时间

  ChatMessage({
    required this.text,
    required this.isUser,
    this.imagePath,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}