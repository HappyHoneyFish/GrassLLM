// 文件路径: lib/ui/widgets/timeline_card.dart

import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../data/models.dart';

class TimelineCard extends StatelessWidget {
  final TimelineEvent event;
  final bool isFirst;
  final bool isLast;

  const TimelineCard({
    super.key,
    required this.event,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    // 依据状态定义视觉颜色
    final bool isCurrent = event.status == EventStatus.current;
    final bool isPast = event.status == EventStatus.past;

    final Color dotColor = isCurrent ? AppConstants.primaryColor : (isPast ? Colors.grey.shade400 : Colors.grey.shade300);
    final Color lineColor = Colors.grey.shade200;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 左侧：时间轴的线与点
          SizedBox(
            width: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 垂直线 (首节点无上半段，尾节点无下半段)
                Column(
                  children: [
                    Expanded(child: Container(width: 2, color: isFirst ? Colors.transparent : lineColor)),
                    Expanded(child: Container(width: 2, color: isLast ? Colors.transparent : lineColor)),
                  ],
                ),
                // 节点圆圈
                Container(
                  width: isCurrent ? 16 : 12,
                  height: isCurrent ? 16 : 12,
                  decoration: BoxDecoration(
                    color: isCurrent ? AppConstants.primaryColor : Colors.white,
                    border: Border.all(
                        color: dotColor,
                        width: isCurrent ? 0 : 2
                    ),
                    shape: BoxShape.circle,
                    boxShadow: isCurrent ? [
                      BoxShadow(color: AppConstants.primaryColor.withOpacity(0.3), blurRadius: 8, spreadRadius: 2)
                    ] : [],
                  ),
                ),
              ],
            ),
          ),

          // 右侧：内容卡片
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0), // 卡片之间的间距
              child: Container(
                decoration: BoxDecoration(
                  color: isCurrent ? Colors.white : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  border: Border.all(
                    color: isCurrent ? AppConstants.primaryColor : Colors.grey.shade200,
                    width: isCurrent ? 1.5 : 1.0,
                  ),
                  boxShadow: isCurrent ? [
                    BoxShadow(color: AppConstants.primaryColor.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ] : [],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题
                    Text(
                      event.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                        color: isCurrent ? AppConstants.textMainColor : AppConstants.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 描述
                    Text(
                      event.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isPast ? Colors.grey.shade500 : AppConstants.textSecondaryColor,
                      ),
                    ),

                    // 动态气象或公式贴士 (仅当前高亮阶段或存在时展示)
                    if (event.dynamicTip != null && event.dynamicTip!.isNotEmpty && isCurrent) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryLightColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.tips_and_updates_outlined, size: 18, color: AppConstants.primaryColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                event.dynamicTip!,
                                style: const TextStyle(fontSize: 13, color: AppConstants.primaryColor, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}