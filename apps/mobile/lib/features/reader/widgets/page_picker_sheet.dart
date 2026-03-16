import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import '../../../core/theme/typography_ext.dart';

class PagePickerSheet extends StatelessWidget {
  final int currentPage;
  final ValueChanged<int> onPageSelected;

  const PagePickerSheet({
    super.key,
    required this.currentPage,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typography;
    const columns = 5;
    final currentRow = (currentPage - 1) ~/ columns;
    // Each cell is roughly 56px tall (48 + 8 spacing)
    const cellHeight = 56.0;
    final initialOffset = (currentRow * cellHeight - cellHeight).clamp(0.0, double.infinity);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  Locales.string(context, 'select_page'),
                  style: typo.headlineMedium
                      .copyWith(color: colors.textPrimary),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              controller: ScrollController(initialScrollOffset: initialOffset),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.2,
              ),
              itemCount: 604,
              itemBuilder: (context, index) {
                final page = index + 1;
                final isCurrent = page == currentPage;
                return GestureDetector(
                  onTap: () {
                    onPageSelected(page);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? colors.gold.withValues(alpha: 0.15)
                          : colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                      border: isCurrent
                          ? Border.all(color: colors.gold, width: 1.5)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$page',
                      style: typo.bodyMedium.copyWith(
                        color: isCurrent ? colors.gold : colors.textPrimary,
                        fontWeight:
                            isCurrent ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
