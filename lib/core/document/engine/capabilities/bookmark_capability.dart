abstract interface class BookmarkCapability {
  Future<List<Bookmark>> get bookmarks;

  void goto(Bookmark bookmark);
}

class Bookmark {
  final String id;
  final String title;
  final int page;
  final List<Bookmark> children;

  Bookmark({
    required this.id,
    required this.title,
    required this.page,
    this.children = const [],
  });
}
