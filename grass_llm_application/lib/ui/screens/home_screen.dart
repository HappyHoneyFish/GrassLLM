// 文件路径: lib/ui/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/constants.dart';
import '../../providers/user_provider.dart';
import '../../providers/timeline_provider.dart';
import '../widgets/timeline_card.dart';
import '../widgets/voice_photo_fab.dart';
import '../widgets/chat_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.read<UserProvider>().profile;
      if (profile != null) {
        context.read<TimelineProvider>().generateTimeline(profile);
      }
    });
  }

  void _showChatBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ChatBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final timelineProvider = context.watch<TimelineProvider>();
    final profile = userProvider.profile;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,

      appBar: AppBar(
        title: Column(
          children: [
            const Text("草场全周期管理"),
            if (profile != null && profile.hasPlanted)
              Text(
                "${profile.location ?? ''} · ${profile.grassType ?? ''} · ${profile.area ?? 0}亩",
                style: const TextStyle(fontSize: 12, color: AppConstants.textSecondaryColor, fontWeight: FontWeight.normal),
              ),
          ],
        ),
      ),

      body: timelineProvider.events.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
          : RefreshIndicator(
        color: AppConstants.primaryColor,
        onRefresh: () async {
          if (profile != null) {
            context.read<TimelineProvider>().generateTimeline(profile);
          }
        },
        child: AnimationLimiter(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            itemCount: timelineProvider.events.length,
            itemBuilder: (BuildContext context, int index) {
              final event = timelineProvider.events[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 500),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: TimelineCard(
                      event: event,
                      isFirst: index == 0,
                      isLast: index == timelineProvider.events.length - 1,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),

      floatingActionButton: VoicePhotoFab(
        onOpenChat: _showChatBottomSheet,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}