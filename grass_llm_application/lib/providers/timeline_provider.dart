// 文件路径: lib/providers/timeline_provider.dart

import 'package:flutter/material.dart';
import '../data/models.dart';
import '../data/network/weather_service.dart';
import '../logic/grass_calculator.dart';

/// 瀑布流时间轴状态管理
class TimelineProvider with ChangeNotifier {
  List<TimelineEvent> _events = [];
  bool _isLoadingWeather = false;

  List<TimelineEvent> get events => _events;
  bool get isLoadingWeather => _isLoadingWeather;

  // ==========================================
  // 1. 基于用户档案生成动态时间轴
  // ==========================================
  void generateTimeline(UserProfile profile) {
    if (!profile.hasPlanted) {
      // 未种草状态的引导时间轴
      _events = [
        TimelineEvent(
          title: "选种规划",
          description: "当前尚未开始种植。请确认意向品种与面积。",
          status: EventStatus.current,
          dynamicTip: "建议：结合本地气候选择抗旱/抗寒品种。",
        ),
        TimelineEvent(
          title: "整地与播种",
          description: "规划好后，进行土地平整和基肥施用。",
          status: EventStatus.future,
        ),
      ];
      notifyListeners();
      return;
    }

    // 已种草状态，基于时间推演
    final int days = profile.plantedDays;
    final double expectedYield = GrassCalculator.calculateExpectedYield(profile);
    final int sheepUnits = GrassCalculator.calculateSheepUnits(profile);

    // 构建四个核心阶段的瀑布流数据
    _events = [
      TimelineEvent(
        title: "选种与播种",
        description: "完成基肥施用与种子播撒。",
        status: days > 5 ? EventStatus.past : EventStatus.current,
      ),
      TimelineEvent(
        title: "出苗与早期管理",
        description: "重点关注出苗率与早期杂草防治。",
        status: _determineStatus(days, 5, 20),
      ),
      TimelineEvent(
        title: "旺盛生长期",
        description: "需水肥高峰期，注意病虫害防治。",
        status: _determineStatus(days, 20, 60),
      ),
      TimelineEvent(
        title: "成熟与刈割收获",
        description: "适时收割保证粗蛋白含量。预估干草总产: ${expectedYield.toStringAsFixed(0)} kg (约可饲喂 $sheepUnits 只羊/半年)。",
        status: days > 60 ? EventStatus.current : EventStatus.future,
      ),
    ];

    notifyListeners();

    // 2. 异步获取天气数据，并追加到当前进行中的阶段
    _fetchAndInjectWeather(profile);
  }

  // ==========================================
  // 2. 判断各个阶段的状态
  // ==========================================
  EventStatus _determineStatus(int currentDays, int startDay, int endDay) {
    if (currentDays < startDay) return EventStatus.future;
    if (currentDays > endDay) return EventStatus.past;
    return EventStatus.current; // 恰好处于该区间
  }

  // ==========================================
  // 3. 异步拉取天气并更新当前卡片
  // ==========================================
  Future<void> _fetchAndInjectWeather(UserProfile profile) async {
    // 这里暂时使用默认的经纬度进行演示（如：甘肃酒泉大致坐标）
    // 实际生产中可通过定位插件获取真实坐标传入
    _isLoadingWeather = true;
    notifyListeners();

    final String weatherStr = await WeatherService.getTodayWeatherOverview(lat: 39.73, lng: 98.48);

    if (weatherStr.isNotEmpty) {
      // 找到当前正在进行中的阶段，注入动态气象提醒
      for (int i = 0; i < _events.length; i++) {
        if (_events[i].status == EventStatus.current) {
          _events[i] = TimelineEvent(
            title: _events[i].title,
            description: _events[i].description,
            status: _events[i].status,
            dynamicTip: "气象贴士：$weatherStr",
          );
          break; // 只更新当前的高亮节点
        }
      }
    }

    _isLoadingWeather = false;
    notifyListeners();
  }
}