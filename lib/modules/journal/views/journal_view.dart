import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:daily_dose/app/constants/app_icons.dart';
import 'package:daily_dose/app/theme/app_colors.dart';
import 'package:daily_dose/app/config/constants.dart';
import 'package:daily_dose/data/models/journal_entry_model.dart';
import 'package:daily_dose/modules/journal/controllers/journal_controller.dart';
import 'package:daily_dose/widgets/loading_state.dart';
import 'package:intl/intl.dart';

/// Journal / Mood Tracker View — Premium Design
///
/// Features mood selector with emoji scale, daily journal entry,
/// tag chips, mood trend mini-chart, and entry history.
class JournalView extends GetView<JournalController> {
  const JournalView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0D0D1A)
          : const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const LoadingState();
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMoodInputCard(isDark),
                      const SizedBox(height: 24),
                      _buildMoodTrend(isDark),
                      const SizedBox(height: 24),
                      _buildEntryHistory(isDark),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ============ HEADER ============

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white,
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                        ),
                      ],
              ),
              child: Icon(
                AppIcons.arrowLeft,
                size: 18,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Journal',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  DateFormat('EEEE, MMM d').format(DateTime.now()),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white54 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============ MOOD INPUT CARD ============

  Widget _buildMoodInputCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.journalAccent.withValues(alpha: 0.2),
                  AppColors.journalAccent.withValues(alpha: 0.05),
                ]
              : [AppColors.journalAccent.withValues(alpha: 0.08), Colors.white],
        ),
        border: Border.all(
          color: isDark
              ? AppColors.journalAccent.withValues(alpha: 0.2)
              : AppColors.journalAccent.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          // Mood emoji selector
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (index) {
                final mood = index + 1;
                final isSelected = controller.selectedMood.value == mood;
                return GestureDetector(
                  onTap: () => controller.selectedMood.value = mood,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isSelected ? 60 : 48,
                    height: isSelected ? 60 : 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? AppColors.moodColors[index].withValues(alpha: 0.2)
                          : (isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.grey.shade100),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.moodColors[index]
                            : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        AppConstants.moodEmojis[index],
                        style: TextStyle(fontSize: isSelected ? 28 : 22),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 6),

          // Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: AppConstants.moodLabels
                .map(
                  (label) => SizedBox(
                    width: 56,
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white38 : Colors.grey,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),

          // Tag chips
          Text(
            'Tags',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 10),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.journalTags.map((tag) {
                final isSelected = controller.selectedTags.contains(tag);
                return GestureDetector(
                  onTap: () => controller.toggleTag(tag),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: isSelected
                          ? AppColors.journalAccent
                          : (isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.grey.shade100),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white54 : Colors.black54),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Journal text
          TextField(
            controller: controller.contentTextController,
            onChanged: (v) => controller.content.value = v,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: 'Write about your day...',
              hintStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.grey,
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 16),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => controller.saveEntry(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.journalAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Save Entry',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ MOOD TREND ============

  Widget _buildMoodTrend(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mood This Week',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 80,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.grey.shade100,
            ),
          ),
          child: Obx(() {
            final trend = controller.moodTrend;
            if (trend.isEmpty || trend.every((v) => v == 0)) {
              return Center(
                child: Text(
                  'Start logging to see your trend',
                  style: TextStyle(
                    color: AppColors.journalAccent.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                ),
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final value = i < trend.length ? trend[i] : 0.0;
                final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 28,
                      height: value > 0 ? (value / 5) * 36 : 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: value > 0
                            ? _moodColor(value)
                            : (isDark ? Colors.white12 : Colors.grey.shade200),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      days[i],
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white38 : Colors.grey,
                      ),
                    ),
                  ],
                );
              }),
            );
          }),
        ),
      ],
    );
  }

  Color _moodColor(double mood) {
    final index = (mood - 1).clamp(0, 4).round();
    return AppColors.moodColors[index];
  }

  // ============ ENTRY HISTORY ============

  Widget _buildEntryHistory(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Entries',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.entries.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.white,
              ),
              child: Center(
                child: Text(
                  'No entries yet',
                  style: TextStyle(
                    color: AppColors.journalAccent.withValues(alpha: 0.5),
                  ),
                ),
              ),
            );
          }

          return Column(
            children: controller.entries
                .take(10)
                .map((entry) => _buildEntryCard(entry, isDark))
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildEntryCard(JournalEntryModel entry, bool isDark) {
    final moodIndex = (entry.mood - 1).clamp(0, 4);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: Key(entry.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => controller.deleteEntry(entry.id),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
            ),
          ),
          child: const Icon(AppIcons.delete, color: Colors.white, size: 24),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.grey.shade100,
            ),
          ),
          child: Row(
            children: [
              // Mood emoji
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.moodColors[moodIndex].withValues(
                    alpha: 0.15,
                  ),
                ),
                child: Center(
                  child: Text(
                    AppConstants.moodEmojis[moodIndex],
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMM d, h:mm a').format(entry.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : Colors.grey,
                      ),
                    ),
                    if (entry.content != null && entry.content!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        entry.content!,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (entry.tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        children: entry.tags
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: AppColors.journalAccent.withValues(
                                    alpha: 0.12,
                                  ),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.journalAccent,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
