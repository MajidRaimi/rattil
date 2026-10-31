import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:imad_flutter/imad_flutter.dart' as imad;

class NastaleeqLoadError extends StatelessWidget {
  final imad.ReadingThemeData themeData;
  final VoidCallback onRetry;

  const NastaleeqLoadError({
    super.key,
    required this.themeData,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: themeData.secondaryTextColor,
          ),
          const SizedBox(height: 12),
          Text(
            Locales.string(context, 'error_loading_surah'),
            style: TextStyle(color: themeData.textColor),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: Text(
              Locales.string(context, 'retry'),
              style: TextStyle(color: themeData.accentColor),
            ),
          ),
        ],
      ),
    );
  }
}
