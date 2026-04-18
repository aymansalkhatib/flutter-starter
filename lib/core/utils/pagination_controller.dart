import 'dart:async';

import 'package:flutter/material.dart';

/// Generic pagination controller for scroll-based pagination.
///
/// Attach [scrollController] to your [ListView] / [CustomScrollView] and call
/// [fetchFirstPage] to start. The controller automatically fetches subsequent
/// pages as the user scrolls toward the bottom.
///
/// Extends [ChangeNotifier] so widgets can listen to [isFetching] and
/// [hasMoreData] changes without extra state management.
///
/// Type parameters:
/// - [T] – item type returned by [fetchPage].
/// - [D] – optional payload (filters, query params) forwarded to [fetchPage].
///
/// Example:
/// ```dart
/// final controller = PaginationController<Post, void>(
///   fetchPage: (page, limit, _) => api.getPosts(page: page, limit: limit),
/// );
/// ```
class PaginationController<T, D> extends ChangeNotifier {
  /// Creates a [PaginationController].
  ///
  /// - [fetchPage] is required — provides the data-fetching logic.
  /// - [pageSize] controls how many items are requested per page.
  /// - [scrollThresholdFactor] is a multiplier of the viewport height that
  ///   determines how early the next fetch is triggered. Defaults to `1.5`
  ///   (fetch when 1.5 screen-heights remain). Increase for slow connections.
  /// - [onError] is called when [fetchPage] throws; if omitted, errors are
  ///   silently suppressed.
  PaginationController({
    required this.fetchPage,
    this.pageSize = 20,
    this.scrollThresholdFactor = 1.5,
    this.onError,
  }) {
    scrollController = ScrollController();
    _scrollListener = _onScroll;
    scrollController.addListener(_scrollListener);
  }

  /// Fetches one page of data.
  ///
  /// - [page] – 1-based page index.
  /// - [limit] – number of items to fetch.
  /// - [data] – optional payload forwarded from [fetchFirstPage].
  final FutureOr<List<T>> Function(int page, int limit, D? data) fetchPage;

  /// Number of items per page. Defaults to `20`.
  final int pageSize;

  /// Multiplier of the viewport height used to determine how early the next
  /// fetch is triggered. Defaults to `1.5` (fetch when 1.5 screen-heights
  /// remain). Increase for slow connections.
  final double scrollThresholdFactor;

  /// Called when [fetchPage] throws. Receives the error and stack trace.
  /// If null, errors are silently suppressed.
  final void Function(Object error, StackTrace stackTrace)? onError;

  /// The [ScrollController] to attach to your scrollable widget.
  late final ScrollController scrollController;

  late final VoidCallback _scrollListener;

  D? _data;
  int _currentPage = 1;
  bool _isFetching = false;
  bool _hasMoreData = true;

  // ─── Getters ──────────────────────────────────────────────────────────────

  /// Whether a fetch operation is currently in progress.
  bool get isFetching => _isFetching;

  /// Whether more pages are available to fetch.
  bool get hasMoreData => _hasMoreData;

  /// The page that will be requested on the next [_fetchNextPage] call.
  int get currentPage => _currentPage;

  // ─── Public API ───────────────────────────────────────────────────────────

  /// Resets state and fetches page 1.
  ///
  /// Asserts in debug mode if called while a fetch is already running.
  Future<List<T>> fetchFirstPage({D? data}) async {
    assert(
      !_isFetching,
      'fetchFirstPage() called while a fetch is already in progress.',
    );
    if (_isFetching) {
      return [];
    }

    _reset(data: data);
    return _fetchNextPage();
  }

  /// Resets pagination state and scrolls back to the top.
  ///
  /// Safe to call even while a fetch is in progress — the in-flight request
  /// result will be ignored once [_isFetching] is cleared.
  void reset() => _reset();

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  // ─── Internal ─────────────────────────────────────────────────────────────

  void _reset({D? data}) {
    _currentPage = 1;
    _isFetching = false;
    _hasMoreData = true;
    _data = data;
    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
    notifyListeners();
  }

  void _onScroll() {
    if (!_hasMoreData || _isFetching) {
      return;
    }
    if (!scrollController.hasClients) {
      return;
    }

    final position = scrollController.position;
    final remaining = position.maxScrollExtent - position.pixels;
    final trigger = position.viewportDimension * scrollThresholdFactor;

    if (remaining <= trigger) {
      _fetchNextPage();
    }
  }

  Future<List<T>> _fetchNextPage() async {
    if (_isFetching || !_hasMoreData) {
      return [];
    }

    _isFetching = true;
    notifyListeners();

    try {
      final items = await fetchPage(_currentPage, pageSize, _data);

      if (items.length < pageSize) {
        _hasMoreData = false;
      } else {
        _currentPage++;
      }

      return items;
    } catch (e, st) {
      onError?.call(e, st);
      return [];
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }
}
