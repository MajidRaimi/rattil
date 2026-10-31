import 'package:flutter/material.dart';

import 'nastaleeq_page_map.dart';

enum NastaleeqPageTurn { initial, jump, swipe }

typedef NastaleeqPageTurnCallback =
    void Function(int page, NastaleeqPageTurn turn);

typedef NastaleeqPageBuilder =
    Widget Function(BuildContext context, int page, bool isCurrent);

class NastaleeqPager extends StatefulWidget {
  final NastaleeqPageMap pageMap;
  final int initialPage;
  final NastaleeqPageTurnCallback onPageTurn;
  final NastaleeqPageBuilder pageBuilder;

  const NastaleeqPager({
    super.key,
    required this.pageMap,
    required this.initialPage,
    required this.onPageTurn,
    required this.pageBuilder,
  });

  @override
  State<NastaleeqPager> createState() => NastaleeqPagerState();
}

class NastaleeqPagerState extends State<NastaleeqPager> {
  late int _currentPage = widget.pageMap.clampPage(widget.initialPage);
  late PageController _controller = _controllerFor(_currentPage);

  NastaleeqPageMap get pageMap => widget.pageMap;

  int get currentPage => _currentPage;

  int get _pageCount => widget.pageMap.pageCount;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onPageTurn(_currentPage, NastaleeqPageTurn.initial);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  PageController _controllerFor(int page) =>
      PageController(initialPage: _pageCount - page);

  void jumpTo(int page) {
    final target = widget.pageMap.clampPage(page);
    setState(() => _currentPage = target);
    if (_controller.hasClients) {
      _controller.jumpToPage(_pageCount - target);
    } else {
      final previous = _controller;
      _controller = _controllerFor(target);
      WidgetsBinding.instance.addPostFrameCallback((_) => previous.dispose());
    }
    widget.onPageTurn(target, NastaleeqPageTurn.jump);
  }

  void _handlePageChanged(int index) {
    final page = _pageCount - index;
    if (page == _currentPage) return;
    setState(() => _currentPage = page);
    widget.onPageTurn(page, NastaleeqPageTurn.swipe);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: PageView.builder(
        controller: _controller,
        itemCount: _pageCount,
        onPageChanged: _handlePageChanged,
        itemBuilder: (context, index) {
          final page = _pageCount - index;
          return widget.pageBuilder(context, page, page == _currentPage);
        },
      ),
    );
  }
}
