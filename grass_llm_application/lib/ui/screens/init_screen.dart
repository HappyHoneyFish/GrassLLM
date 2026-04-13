// 文件路径: lib/ui/screens/init_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../data/models.dart';
import '../../providers/user_provider.dart';
import 'home_screen.dart';
import '../../core/theme.dart';

class InitScreen extends StatefulWidget {
  const InitScreen({super.key});

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  // 0 = 未选择分支， 1 = 已种草 (分支A)， 2 = 未种草 (分支B)
  int _currentStep = 0;

  // 表单控制器
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _grassTypeController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _locationController.dispose();
    _grassTypeController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  // ==========================================
  // 核心逻辑：保存档案并跳转主页
  // ==========================================
  Future<void> _submitProfile() async {
    // 基础校验
    if (_locationController.text.trim().isEmpty || _areaController.text.trim().isEmpty) {
      AppUtils.showToast(context, "请填写完整基本信息", isError: true);
      return;
    }

    final bool hasPlanted = _currentStep == 1;

    if (hasPlanted && _grassTypeController.text.trim().isEmpty) {
      AppUtils.showToast(context, "请填写种植品种", isError: true);
      return;
    }
    if (hasPlanted && _selectedDate == null) {
      AppUtils.showToast(context, "请选择种植日期", isError: true);
      return;
    }

    final double? area = double.tryParse(_areaController.text.trim());
    if (area == null || area <= 0) {
      AppUtils.showToast(context, "面积格式不正确", isError: true);
      return;
    }

    // 构建用户档案
    final UserProfile profile = UserProfile(
      hasPlanted: hasPlanted,
      location: _locationController.text.trim(),
      area: area,
      grassType: hasPlanted ? _grassTypeController.text.trim() : null,
      plantDate: hasPlanted ? _selectedDate : null,
    );

    // 存入本地并更新全局状态
    final success = await context.read<UserProvider>().updateProfile(profile);

    if (success && mounted) {
      // 跃迁至主页
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      AppUtils.showToast(context, "档案保存失败，请重试", isError: true);
    }
  }

  // ==========================================
  // UI 渲染方法
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("建档初始化"),
        leading: _currentStep != 0
            ? IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => setState(() => _currentStep = 0),
        )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding * 1.5),
          child: _currentStep == 0 ? _buildBranchSelection() : _buildForm(),
        ),
      ),
    );
  }

  // 1. 分支选择 UI
  Widget _buildBranchSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "欢迎来到草业智能体",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppConstants.textMainColor),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          "请问您当前的种植状态是？",
          style: TextStyle(fontSize: 16, color: AppConstants.textSecondaryColor),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),

        // 分支 A: 已种草
        _buildChoiceCard(
          icon: Icons.eco_rounded,
          title: "我已经种草了",
          subtitle: "记录信息，开启全生命周期管理",
          onTap: () => setState(() => _currentStep = 1),
        ),
        const SizedBox(height: 24),

        // 分支 B: 未种草
        _buildChoiceCard(
          icon: Icons.map_rounded,
          title: "我还没开始种",
          subtitle: "智能规划，推荐适宜当地的草种",
          onTap: () => setState(() => _currentStep = 2),
        ),
      ],
    );
  }

  Widget _buildChoiceCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(color: AppConstants.primaryColor.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppConstants.primaryLightColor, shape: BoxShape.circle),
              child: Icon(icon, color: AppConstants.primaryColor, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.textMainColor)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: AppConstants.textSecondaryColor)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppConstants.textHintColor, size: 18),
          ],
        ),
      ),
    );
  }

  // 2. 极简表单 UI
  Widget _buildForm() {
    final isPlanted = _currentStep == 1;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isPlanted ? "完善草场档案" : "完善意向规划",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppConstants.textMainColor),
          ),
          const SizedBox(height: 8),
          Text(
            isPlanted ? "以便大模型为您推演精准的生长阶段" : "告诉大模型您的位置，为您推荐品种",
            style: const TextStyle(fontSize: 14, color: AppConstants.textSecondaryColor),
          ),
          const SizedBox(height: 32),

          _buildTextField(label: "您的所在地", hint: "例如：甘肃酒泉", controller: _locationController, icon: Icons.location_on_outlined),
          const SizedBox(height: 20),

          _buildTextField(label: isPlanted ? "实际种植面积 (亩)" : "意向种植面积 (亩)", hint: "例如：15", controller: _areaController, icon: Icons.square_foot_outlined, isNumber: true),
          const SizedBox(height: 20),

          if (isPlanted) ...[
            _buildTextField(label: "种植什么草", hint: "例如：紫花苜蓿 / 燕麦", controller: _grassTypeController, icon: Icons.grass_outlined),
            const SizedBox(height: 20),

            // 日期选择器
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  builder: (context, child) => Theme(data: AppTheme.lightTheme, child: child!),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, color: AppConstants.primaryColor),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate == null ? "请选择大致的播种日期" : "播种日期: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}",
                      style: TextStyle(fontSize: 16, color: _selectedDate == null ? AppConstants.textHintColor : AppConstants.textMainColor),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],

          const SizedBox(height: 20),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _submitProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius)),
                elevation: 0,
              ),
              child: const Text("开启智能管家", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // 提取输入框组件
  Widget _buildTextField({required String label, required String hint, required TextEditingController controller, required IconData icon, bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppConstants.primaryColor),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
      ),
    );
  }
}