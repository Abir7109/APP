import 'package:material_ui/material_ui.dart';

class MoodInfo {
  const MoodInfo({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final int value;
  final String label;
  final IconData icon;
  final Color color;
}

const moodScale = <MoodInfo>[
  MoodInfo(
    value: 1,
    label: 'Low',
    icon: Icons.sentiment_very_dissatisfied_rounded,
    color: Color(0xFF68B4FF),
  ),
  MoodInfo(
    value: 2,
    label: 'Meh',
    icon: Icons.sentiment_dissatisfied_rounded,
    color: Color(0xFF9B51E0),
  ),
  MoodInfo(
    value: 3,
    label: 'Okay',
    icon: Icons.sentiment_neutral_rounded,
    color: Color(0xFFFF9500),
  ),
  MoodInfo(
    value: 4,
    label: 'Good',
    icon: Icons.sentiment_satisfied_rounded,
    color: Color(0xFFFF7B83),
  ),
  MoodInfo(
    value: 5,
    label: 'Amazing',
    icon: Icons.sentiment_very_satisfied_rounded,
    color: Color(0xFFFF4576),
  ),
];

MoodInfo moodInfo(int mood) {
  final index = (mood - 1).clamp(0, moodScale.length - 1);
  return moodScale[index];
}
