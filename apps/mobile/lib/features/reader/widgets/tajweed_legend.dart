import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

class _TajweedRule {
  final Color color;
  final String nameAr;
  final String nameEn;
  final String descAr;
  final String descEn;

  const _TajweedRule({
    required this.color,
    required this.nameAr,
    required this.nameEn,
    required this.descAr,
    required this.descEn,
  });
}

const _rules = [
  _TajweedRule(
    color: Color(0xFF09B000),
    nameAr: 'غنة',
    nameEn: 'Ghunnah',
    descAr: 'صوت أنفي مع إخفاء أو إدغام',
    descEn: 'Nasal sound with concealment',
  ),
  _TajweedRule(
    color: Color(0xFF2FADFF),
    nameAr: 'قلقلة',
    nameEn: 'Qalqalah',
    descAr: 'اهتزاز في حروف قطب جد',
    descEn: 'Echo on ق ط ب ج د',
  ),
  _TajweedRule(
    color: Color(0xFFCE9E00),
    nameAr: 'مد ٢',
    nameEn: 'Madd 2',
    descAr: 'مد طبيعي حركتان',
    descEn: 'Natural elongation',
  ),
  _TajweedRule(
    color: Color(0xFFFF7B00),
    nameAr: 'مد ٢-٦',
    nameEn: 'Madd 2-6',
    descAr: 'مد جائز منفصل',
    descEn: 'Permissible elongation',
  ),
  _TajweedRule(
    color: Color(0xFFF40000),
    nameAr: 'مد ٤-٥',
    nameEn: 'Madd 4-5',
    descAr: 'مد واجب متصل',
    descEn: 'Obligatory elongation',
  ),
  _TajweedRule(
    color: Color(0xFFB50000),
    nameAr: 'مد ٦',
    nameEn: 'Madd 6',
    descAr: 'مد لازم',
    descEn: 'Necessary elongation',
  ),
  _TajweedRule(
    color: Color(0xFF3F48E6),
    nameAr: 'تفخيم',
    nameEn: 'Tafkhim',
    descAr: 'تفخيم لفظ الجلالة',
    descEn: 'Heavy pronunciation',
  ),
  _TajweedRule(
    color: Color(0xFFA5A5A5),
    nameAr: 'صامت',
    nameEn: 'Silent',
    descAr: 'حرف لا ينطق',
    descEn: 'Not pronounced',
  ),
];

Color _invertColor(Color c) {
  final r = (c.r * 255).round();
  final g = (c.g * 255).round();
  final b = (c.b * 255).round();
  return Color.fromARGB(255, 255 - r, 255 - g, 255 - b);
}

class TajweedLegend extends StatelessWidget {
  final bool isDark;

  const TajweedLegend({super.key, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final isArabic = Locales.currentLocale(context)?.languageCode == 'ar';
    final descColor = isDark ? const Color(0xFF707070) : const Color(0xFF9A9A9A);

    return Column(
      children: _rules.map((rule) {
        final dotColor = isDark ? _invertColor(rule.color) : rule.color;
        final name = isArabic ? rule.nameAr : rule.nameEn;
        final desc = isArabic ? rule.descAr : rule.descEn;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: dotColor.withValues(alpha: 0.15),
                    border: Border.all(color: dotColor, width: 1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontFamily: 'NeueFrutigerWorld',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: dotColor,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  desc,
                  style: TextStyle(
                    fontFamily: 'NeueFrutigerWorld',
                    fontSize: 9,
                    color: descColor,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
