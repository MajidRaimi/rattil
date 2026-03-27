import 'package:flutter/material.dart';

const Map<String, IconData> collectionIconMap = {
  'bookmark': Icons.bookmark_rounded,
  'mosque': Icons.mosque_rounded,
  'menu_book': Icons.menu_book_rounded,
  'star': Icons.star_rounded,
  'favorite': Icons.favorite_rounded,
  'lightbulb': Icons.lightbulb_rounded,
  'school': Icons.school_rounded,
  'auto_stories': Icons.auto_stories_rounded,
  'calendar_month': Icons.calendar_month_rounded,
  'folder': Icons.folder_rounded,
  'label': Icons.label_rounded,
  'repeat': Icons.repeat_rounded,
};

const List<String> suggestedIconNames = [
  'bookmark',
  'mosque',
  'menu_book',
  'star',
  'favorite',
  'lightbulb',
  'school',
  'auto_stories',
  'calendar_month',
  'folder',
  'label',
  'repeat',
];

IconData getCollectionIcon(String name) {
  return collectionIconMap[name] ?? Icons.bookmark_rounded;
}
