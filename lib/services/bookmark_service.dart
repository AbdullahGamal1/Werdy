// Bookmark Service - خدمة العلامات المرجعية

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/bookmark.dart';

class BookmarkService {
  static final BookmarkService _instance = BookmarkService._internal();
  factory BookmarkService() => _instance;
  BookmarkService._internal();

  static const String _bookmarksKey = 'bookmarks';
  static const String _favoritesKey = 'favorites';
  static const String _lastReadKey = 'last_read';

  List<Bookmark> _bookmarks = [];
  List<FavoriteVerse> _favorites = [];
  LastReadPosition? _lastReadPosition;

  // Load all data
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load bookmarks
    final bookmarksJson = prefs.getString(_bookmarksKey);
    if (bookmarksJson != null) {
      final List<dynamic> decoded = json.decode(bookmarksJson);
      _bookmarks = decoded
          .map((item) => Bookmark.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    // Load favorites
    final favoritesJson = prefs.getString(_favoritesKey);
    if (favoritesJson != null) {
      final List<dynamic> decoded = json.decode(favoritesJson);
      _favorites = decoded
          .map((item) => FavoriteVerse.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    // Load last read position
    final lastReadJson = prefs.getString(_lastReadKey);
    if (lastReadJson != null) {
      _lastReadPosition = LastReadPosition.fromJson(
        json.decode(lastReadJson) as Map<String, dynamic>,
      );
    }
  }

  // Save all data
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save bookmarks
    final bookmarksJson = json.encode(
      _bookmarks.map((b) => b.toJson()).toList(),
    );
    await prefs.setString(_bookmarksKey, bookmarksJson);

    // Save favorites
    final favoritesJson = json.encode(
      _favorites.map((f) => f.toJson()).toList(),
    );
    await prefs.setString(_favoritesKey, favoritesJson);

    // Save last read position
    if (_lastReadPosition != null) {
      final lastReadJson = json.encode(_lastReadPosition!.toJson());
      await prefs.setString(_lastReadKey, lastReadJson);
    }
  }

  // Bookmarks operations
  Future<void> addBookmark(Bookmark bookmark) async {
    _bookmarks.add(bookmark);
    await _saveData();
  }

  Future<void> removeBookmark(String id) async {
    _bookmarks.removeWhere((b) => b.id == id);
    await _saveData();
  }

  Future<void> updateBookmark(Bookmark bookmark) async {
    final index = _bookmarks.indexWhere((b) => b.id == bookmark.id);
    if (index != -1) {
      _bookmarks[index] = bookmark;
      await _saveData();
    }
  }

  List<Bookmark> getAllBookmarks() {
    return List.unmodifiable(_bookmarks);
  }

  List<Bookmark> getBookmarksBySurah(int surahNumber) {
    return _bookmarks.where((b) => b.surahNumber == surahNumber).toList();
  }

  bool isBookmarked(int surahNumber, int verseNumber) {
    return _bookmarks.any(
      (b) => b.surahNumber == surahNumber && b.verseNumber == verseNumber,
    );
  }

  // Favorites operations
  Future<void> addFavorite(FavoriteVerse favorite) async {
    // Remove if already exists
    _favorites.removeWhere(
      (f) =>
          f.surahNumber == favorite.surahNumber &&
          f.verseNumber == favorite.verseNumber,
    );
    _favorites.add(favorite);
    await _saveData();
  }

  Future<void> removeFavorite(int surahNumber, int verseNumber) async {
    _favorites.removeWhere(
      (f) => f.surahNumber == surahNumber && f.verseNumber == verseNumber,
    );
    await _saveData();
  }

  Future<void> updateFavorite(FavoriteVerse favorite) async {
    final index = _favorites.indexWhere(
      (f) =>
          f.surahNumber == favorite.surahNumber &&
          f.verseNumber == favorite.verseNumber,
    );
    if (index != -1) {
      _favorites[index] = favorite;
      await _saveData();
    }
  }

  List<FavoriteVerse> getAllFavorites() {
    return List.unmodifiable(_favorites);
  }

  List<FavoriteVerse> getFavoritesByTag(String tag) {
    return _favorites.where((f) => f.tags.contains(tag)).toList();
  }

  bool isFavorite(int surahNumber, int verseNumber) {
    return _favorites.any(
      (f) => f.surahNumber == surahNumber && f.verseNumber == verseNumber,
    );
  }

  FavoriteVerse? getFavorite(int surahNumber, int verseNumber) {
    try {
      return _favorites.firstWhere(
        (f) => f.surahNumber == surahNumber && f.verseNumber == verseNumber,
      );
    } catch (e) {
      return null;
    }
  }

  // Last read position operations
  Future<void> updateLastReadPosition(LastReadPosition position) async {
    _lastReadPosition = position;
    await _saveData();
  }

  LastReadPosition? getLastReadPosition() {
    return _lastReadPosition;
  }

  Future<void> clearLastReadPosition() async {
    _lastReadPosition = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastReadKey);
  }

  // Utility methods
  Future<void> clearAllBookmarks() async {
    _bookmarks.clear();
    await _saveData();
  }

  Future<void> clearAllFavorites() async {
    _favorites.clear();
    await _saveData();
  }

  Future<void> clearAll() async {
    _bookmarks.clear();
    _favorites.clear();
    _lastReadPosition = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bookmarksKey);
    await prefs.remove(_favoritesKey);
    await prefs.remove(_lastReadKey);
  }

  // Export data
  Map<String, dynamic> exportData() {
    return {
      'bookmarks': _bookmarks.map((b) => b.toJson()).toList(),
      'favorites': _favorites.map((f) => f.toJson()).toList(),
      'lastRead': _lastReadPosition?.toJson(),
    };
  }

  // Import data
  Future<void> importData(Map<String, dynamic> data) async {
    if (data.containsKey('bookmarks')) {
      _bookmarks = (data['bookmarks'] as List<dynamic>)
          .map((item) => Bookmark.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    if (data.containsKey('favorites')) {
      _favorites = (data['favorites'] as List<dynamic>)
          .map((item) => FavoriteVerse.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    if (data.containsKey('lastRead') && data['lastRead'] != null) {
      _lastReadPosition = LastReadPosition.fromJson(
        data['lastRead'] as Map<String, dynamic>,
      );
    }

    await _saveData();
  }
}
