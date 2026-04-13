// 文件路径: lib/logic/grass_calculator.dart

import '../data/models.dart';

/// 草业本地轻量级计算器 (业务逻辑层)
class GrassCalculator {

  // ==========================================
  // 1. 推演当前生长阶段
  // ==========================================
  static String getCurrentStage(UserProfile profile) {
    if (!profile.hasPlanted || profile.plantDate == null) {
      return "尚未种植";
    }

    final int days = profile.plantedDays;
    final String type = profile.grassType ?? "未知草种";

    // 针对紫花苜蓿的经验周期
    if (type.contains("苜蓿")) {
      if (days < 10) return "出苗期";
      if (days < 40) return "分枝期";
      if (days < 60) return "现蕾期 (关键需水期)";
      if (days < 75) return "初花期 (最佳刈割期)";
      return "结荚/成熟期";
    }
    // 针对燕麦/禾本科的经验周期
    else if (type.contains("燕麦") || type.contains("玉米")) {
      if (days < 15) return "苗期";
      if (days < 40) return "拔节期";
      if (days < 60) return "孕穗期 (需水肥高峰)";
      if (days < 80) return "抽穗/灌浆期";
      return "完熟期";
    }

    // 通用兜底逻辑
    if (days < 30) return "苗期阶段";
    if (days < 60) return "旺盛生长期";
    return "成熟收获期";
  }

  // ==========================================
  // 2. 估算预期干草产量 (单位：公斤)
  // ==========================================
  static double calculateExpectedYield(UserProfile profile) {
    if (profile.area == null || profile.area! <= 0) return 0.0;

    final String type = profile.grassType ?? "";
    double yieldPerMu = 600.0; // 默认基础亩产 600 kg

    // 基于牧草品种的经验亩产 (仅作本地预估估算参考)
    if (type.contains("苜蓿")) {
      yieldPerMu = 1000.0; // 优良紫花苜蓿干草亩产约 800-1200kg
    } else if (type.contains("燕麦")) {
      yieldPerMu = 1500.0; // 饲用燕麦干草亩产约 1200-1800kg
    } else if (type.contains("青贮玉米")) {
      yieldPerMu = 3500.0; // 青贮玉米(鲜重换算)产量极高
    }

    return profile.area! * yieldPerMu;
  }

  // ==========================================
  // 3. 估算载畜量 (能养多少只标准羊单位)
  // ==========================================
  /// 假设一只标准羊 (50kg) 每天需要吃约 1.5kg 干草
  /// 每年舍饲按 180 天计算
  static int calculateSheepUnits(UserProfile profile) {
    final double totalYield = calculateExpectedYield(profile);
    if (totalYield <= 0) return 0;

    const double dailyConsumptionPerSheep = 1.5;
    const int feedDays = 180; // 冬春季补饲天数

    // 羊只数量 = 总产量 / (单只日采食量 * 饲喂天数)
    double sheepCount = totalYield / (dailyConsumptionPerSheep * feedDays);

    return sheepCount.floor(); // 向下取整，确保草料充足
  }
}