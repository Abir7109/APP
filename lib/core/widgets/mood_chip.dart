import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/moods.dart';
import 'mood_face.dart';
import 'press_scale.dart';

/// One face in a mood row.
///
/// Tapping gives a spring pop, a soft colored glow, and a light haptic so
/// choosing a mood feels like a real choice rather than toggling an icon.
class MoodChip extends StatelessWidget {
  const MoodChip({
    super.key,
    required this.mood,
    required this.selected,
    required this.onTap,
    this.size = 56,
  });

  final MoodInfo mood;
  final bool selected;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Semantics(
      button: true,
      selected: selected,
      label: mood.label,
      child: PressScale(
        scale: 0.92,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: selected && !reduceMotion ? 1.06 : 1,
                  duration: selected
                      ? const Duration(milliseconds: 360)
                      : AppDurations.fast,
                  curve: selected ? Curves.easeOutBack : Curves.easeOutCubic,
                  child: AnimatedContainer(
                    duration: AppDurations.normal,
                    curve: Curves.easeOutCubic,
                    width: size,
                    height: size,
                    padding: EdgeInsets.all(size * 0.09),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? mood.color.withValues(alpha: 0.12)
                          : Colors.transparent,
                      border: Border.all(
                        color: selected
                            ? mood.color.withValues(alpha: 0.8)
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: selected && !reduceMotion
                          ? [
                              BoxShadow(
                                color: mood.color.withValues(alpha: 0.34),
                                blurRadius: size * 0.34,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: MoodFace(
                      mood: mood.value,
                      color: mood.color,
                      size: size * 0.82,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                AnimatedDefaultTextStyle(
                  duration: AppDurations.fast,
                  curve: Curves.easeOut,
                  style: context.texts.labelSmall?.copyWith(
                        color: selected ? colors.text : colors.muted,
                        fontWeight:
                            selected ? FontWeight.w800 : FontWeight.w500,
                      ) ??
                      const TextStyle(),
                  child: Text(
                    mood.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
