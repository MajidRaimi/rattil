import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import '../../../core/theme/typography_ext.dart';
import '../../../core/utils/collection_icons.dart';

class CreateCollectionSheet extends StatefulWidget {
  final String? initialTitle;
  final String? initialIcon;

  const CreateCollectionSheet({
    super.key,
    this.initialTitle,
    this.initialIcon,
  });

  @override
  State<CreateCollectionSheet> createState() => _CreateCollectionSheetState();
}

class _CreateCollectionSheetState extends State<CreateCollectionSheet> {
  late final TextEditingController _titleController;
  late String _selectedIcon;

  bool get _isEditing => widget.initialTitle != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _selectedIcon = widget.initialIcon ?? 'bookmark';
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              Locales.string(
                  context, _isEditing ? 'edit_collection' : 'new_collection'),
              style: typo.headlineMedium.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // Title field
            TextField(
              controller: _titleController,
              autofocus: true,
              style: typo.bodyLarge.copyWith(color: colors.textPrimary),
              decoration: InputDecoration(
                hintText:
                    Locales.string(context, 'collection_title_hint'),
                hintStyle:
                    typo.bodyLarge.copyWith(color: colors.textTertiary),
                filled: true,
                fillColor: colors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.gold, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),

            // Icon picker label
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                Locales.string(context, 'choose_icon').toUpperCase(),
                style: typo.bodySmall.copyWith(
                  color: colors.goldDim,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Icon grid
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: suggestedIconNames.map((name) {
                final isSelected = name == _selectedIcon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.gold.withValues(alpha: 0.15)
                          : colors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? colors.gold : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      getCollectionIcon(name),
                      color: isSelected ? colors.gold : colors.textSecondary,
                      size: 22,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Create/Save button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () {
                  final title = _titleController.text.trim();
                  if (title.isEmpty) return;
                  Navigator.pop(context, (title, _selectedIcon));
                },
                style: FilledButton.styleFrom(
                  backgroundColor: colors.gold,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  Locales.string(
                      context, _isEditing ? 'save' : 'create'),
                  style: typo.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
