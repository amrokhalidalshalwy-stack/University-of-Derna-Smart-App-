import 'package:cloud_firestore/cloud_firestore.dart';

/// مساعد Pagination موحّد للمشروع
class PaginationHelper<T> {
  final int pageSize;
  final Query<Map<String, dynamic>> baseQuery;
  final T Function(DocumentSnapshot<Map<String, dynamic>>) fromDoc;

  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoading = false;
  final List<T> _items = [];

  PaginationHelper({
    required this.baseQuery,
    required this.fromDoc,
    this.pageSize = 20,
  });

  List<T> get items => List.unmodifiable(_items);
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;

  Future<List<T>> loadNextPage() async {
    if (_isLoading || !_hasMore) return [];

    _isLoading = true;
    try {
      Query<Map<String, dynamic>> query = baseQuery.limit(pageSize);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty || snapshot.docs.length < pageSize) {
        _hasMore = false;
      }

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        final newItems = snapshot.docs.map(fromDoc).toList();
        _items.addAll(newItems);
        return newItems;
      }
    } finally {
      _isLoading = false;
    }
    return [];
  }

  void reset() {
    _lastDocument = null;
    _hasMore = true;
    _isLoading = false;
    _items.clear();
  }
}
