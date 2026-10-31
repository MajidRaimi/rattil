import 'package:flutter/material.dart';

import 'nastaleeq_layout.dart';

class NastaleeqSurahHeader extends StatelessWidget {
  final String title;
  final TextStyle style;
  final TextHeightBehavior? heightBehavior;
  final Color accent;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final bool fitsSlot;

  const NastaleeqSurahHeader({
    super.key,
    required this.title,
    required this.style,
    required this.heightBehavior,
    required this.accent,
  }) : margin = const EdgeInsets.symmetric(vertical: kNastaleeqHeaderOuterV),
       padding = const EdgeInsets.symmetric(
         vertical: kNastaleeqHeaderInnerV,
         horizontal: kNastaleeqHeaderInnerH,
       ),
       fitsSlot = false;

  const NastaleeqSurahHeader.slotted({
    super.key,
    required this.title,
    required this.style,
    required this.heightBehavior,
    required this.accent,
  }) : margin = const EdgeInsets.symmetric(
         vertical: kNastaleeqPrintedHeaderMarginV,
       ),
       padding = const EdgeInsets.symmetric(horizontal: kNastaleeqHeaderInnerH),
       fitsSlot = true;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      title,
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
      textHeightBehavior: heightBehavior,
      textScaler: fitsSlot ? TextScaler.noScaling : null,
      style: style,
    );
    return Padding(
      padding: margin,
      child: NastaleeqSurahFrame(
        accent: accent,
        padding: padding,
        child: fitsSlot
            ? Center(
                child: FittedBox(fit: BoxFit.scaleDown, child: label),
              )
            : label,
      ),
    );
  }
}

class NastaleeqSurahFrame extends StatelessWidget {
  final Color accent;
  final EdgeInsets padding;
  final Widget child;

  const NastaleeqSurahFrame({
    super.key,
    required this.accent,
    required this.padding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        border: Border.all(
          color: accent.withValues(alpha: 0.55),
          width: kNastaleeqHeaderBorder,
        ),
        borderRadius: BorderRadius.circular(10),
        color: accent.withValues(alpha: 0.06),
      ),
      child: child,
    );
  }
}

class NastaleeqBasmala extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextHeightBehavior? heightBehavior;
  final bool fitsSlot;

  const NastaleeqBasmala({
    super.key,
    required this.text,
    required this.style,
    required this.heightBehavior,
  }) : fitsSlot = false;

  const NastaleeqBasmala.slotted({
    super.key,
    required this.text,
    required this.style,
    required this.heightBehavior,
  }) : fitsSlot = true;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text,
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
      textHeightBehavior: heightBehavior,
      textScaler: fitsSlot ? TextScaler.noScaling : null,
      softWrap: !fitsSlot,
      style: style,
    );
    return fitsSlot
        ? Center(child: label)
        : Padding(
            padding: const EdgeInsets.only(bottom: kNastaleeqBasmalaGap),
            child: label,
          );
  }
}
