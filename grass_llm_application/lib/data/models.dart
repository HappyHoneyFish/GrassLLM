// 文件路径: lib/data/models.dart

import 'dart:convert';


class UserProfile {
  final bool hasPlanted;
  final String? location;
  final String? grassType;
  final double? area;
  final DateTime? plantDate;

  UserProfile({
    required this.hasPlanted,
    this.location,
    this.grassType,
    this.area,
    this.plantDate,
  });

  int get plantedDays {
    if (plantDate == null) return 0;
    return DateTime.now().difference(plantDate!).inDays;
  }

  Map<String, dynamic> toMap() {
    return {
      'hasPlanted': hasPlanted,
      'location': location,
      'grassType': grassType,
      'area': area,
      'plantDate': plantDate?.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      hasPlanted: map['hasPlanted'] ?? false,
      location: map['location'],
      grassType: map['grassType'],
      area: map['area']?.toDouble(),
      plantDate: map['plantDate'] != null ? DateTime.parse(map['plantDate']) : null,
    );
  }

  String toJson() => json.encode(toMap());
  factory UserProfile.fromJson(String source) => UserProfile.fromMap(json.decode(source));
}


enum EventStatus {
  past,
  current,
  future
}

class TimelineEvent {
  final String title;
  final String description;
  final EventStatus status;
  final String? dynamicTip;

  TimelineEvent({
    required this.title,
    required this.description,
    required this.status,
    this.dynamicTip,
  });
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String? imagePath;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.imagePath,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}