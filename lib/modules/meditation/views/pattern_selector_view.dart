import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:daily_dose/app/constants/app_icons.dart';
import 'package:get/get.dart';
import 'package:daily_dose/app/theme/app_colors.dart';
import 'package:daily_dose/app/theme/app_spacing.dart';
import 'package:daily_dose/modules/meditation/controllers/meditation_controller.dart';
import 'package:daily_dose/widgets/app_button.dart';
import 'package:daily_dose/widgets/app_input.dart';
import 'package:daily_dose/widgets/app_card.dart';
import 'package:daily_dose/widgets/app_toast.dart';

/// Pattern selector view for creating custom patterns
class PatternSelectorView extends GetView<MeditationController> {
  const PatternSelectorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Breathing Patterns')),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.separated(
                padding: AppSpacing.screenPadding,
                itemCount: controller.patterns.length,
                separatorBuilder: (_, __) => AppSpacing.vGapSm,
                itemBuilder: (context, index) {
                  final pattern = controller.patterns[index];
                  final isSelected =
                      controller.selectedPattern.value?.id == pattern.id;

                  return AppCard(
                    onTap: () {
                      controller.selectPattern(pattern);
                      Get.back();
                    },
                    borderColor: isSelected ? AppColors.meditationAccent : null,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    pattern.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  if (pattern.isCustom) ...[
                                    AppSpacing.hGapSm,
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.meditationAccent
                                            .withValues(alpha: 0.1),
                                        borderRadius: AppSpacing.borderRadiusSm,
                                      ),
                                      child: Text(
                                        'Custom',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: AppColors.meditationAccent,
                                            ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              AppSpacing.vGapXs,
                              Text(
                                'Inhale ${pattern.inhale}s · Hold ${pattern.hold1}s · Exhale ${pattern.exhale}s · Hold ${pattern.hold2}s',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              AppSpacing.vGapXs,
                              Text(
                                '${pattern.cycleDuration}s per cycle',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: AppColors.meditationAccent,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        if (pattern.isCustom)
                          IconButton(
                            icon: Icon(
                              AppIcons.delete,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            onPressed: () =>
                                controller.deletePattern(pattern.id),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: AppSpacing.screenPadding,
            child: AppButton(
              label: 'Create Custom Pattern',
              icon: AppIcons.add,
              isFullWidth: true,
              onPressed: () => _showCreatePatternDialog(context),
            ),
          ),
          AppSpacing.vGapMd,
        ],
      ),
    );
  }

  void _showCreatePatternDialog(BuildContext context) {
    final nameController = TextEditingController();
    final inhaleController = TextEditingController(text: '4');
    final hold1Controller = TextEditingController(text: '4');
    final exhaleController = TextEditingController(text: '4');
    final hold2Controller = TextEditingController(text: '4');

    Get.dialog(
      AlertDialog(
        title: const Text('Create Custom Pattern'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppInput(
                controller: nameController,
                label: 'Pattern Name',
                hint: 'e.g., My Pattern',
              ),
              AppSpacing.vGapMd,
              Row(
                children: [
                  Expanded(
                    child: AppNumberInput(
                      controller: inhaleController,
                      label: 'Inhale (s)',
                      allowDecimal: false,
                    ),
                  ),
                  AppSpacing.hGapSm,
                  Expanded(
                    child: AppNumberInput(
                      controller: hold1Controller,
                      label: 'Hold (s)',
                      allowDecimal: false,
                    ),
                  ),
                ],
              ),
              AppSpacing.vGapMd,
              Row(
                children: [
                  Expanded(
                    child: AppNumberInput(
                      controller: exhaleController,
                      label: 'Exhale (s)',
                      allowDecimal: false,
                    ),
                  ),
                  AppSpacing.hGapSm,
                  Expanded(
                    child: AppNumberInput(
                      controller: hold2Controller,
                      label: 'Hold (s)',
                      allowDecimal: false,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                AppToast.error(context, 'Please enter a pattern name');
                return;
              }

              controller.createCustomPattern(
                name: nameController.text.trim(),
                inhale: int.tryParse(inhaleController.text) ?? 4,
                hold1: int.tryParse(hold1Controller.text) ?? 4,
                exhale: int.tryParse(exhaleController.text) ?? 4,
                hold2: int.tryParse(hold2Controller.text) ?? 4,
              );
              Get.back();
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
