import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:translator_app/data/models/translation_history_model.dart';
import 'package:translator_app/data/repositories/history_store.dart';

class SqliteHistoryStore implements HistoryStore {
  static const _historyPrefsKey = 'translation_history_items_v1';
  static const _categoriesPrefsKey = 'translation_categories_v1';

  Database? _database;

  Future<Database> _open() async {
    final existing = _database;
    if (existing != null) return existing;

    final path = p.join(await getDatabasesPath(), 'translator_history.db');
    final database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE history (
            id TEXT PRIMARY KEY,
            source_text TEXT NOT NULL,
            translated_text TEXT NOT NULL,
            source_language_code TEXT NOT NULL,
            source_language_name TEXT NOT NULL,
            source_language_flag TEXT NOT NULL,
            target_language_code TEXT NOT NULL,
            target_language_name TEXT NOT NULL,
            target_language_flag TEXT NOT NULL,
            timestamp INTEGER NOT NULL,
            is_favorite INTEGER NOT NULL,
            category TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE categories (
            position INTEGER PRIMARY KEY,
            name TEXT NOT NULL
          )
        ''');
      },
    );
    await _migratePreferences(database);
    _database = database;
    return database;
  }

  Future<void> _migratePreferences(Database database) async {
    final prefs = await SharedPreferences.getInstance();
    final historyCount = Sqflite.firstIntValue(
      await database.rawQuery('SELECT COUNT(*) FROM history'),
    );
    if ((historyCount ?? 0) == 0) {
      final raw = prefs.getString(_historyPrefsKey);
      if (raw != null && raw.isNotEmpty) {
        try {
          final list = jsonDecode(raw);
          if (list is List) {
            final batch = database.batch();
            for (final entry in list) {
              if (entry is Map) {
                final item = TranslationHistoryItem.fromMap(
                  Map<String, dynamic>.from(entry),
                );
                batch.insert('history', _toRow(item));
              }
            }
            await batch.commit(noResult: true);
          }
        } catch (_) {}
      }
    }

    final categoryCount = Sqflite.firstIntValue(
      await database.rawQuery('SELECT COUNT(*) FROM categories'),
    );
    if ((categoryCount ?? 0) == 0) {
      final names = prefs.getStringList(_categoriesPrefsKey);
      if (names != null && names.isNotEmpty) {
        final batch = database.batch();
        for (var i = 0; i < names.length; i++) {
          batch.insert('categories', {'position': i, 'name': names[i]});
        }
        await batch.commit(noResult: true);
      }
    }

    await prefs.remove(_historyPrefsKey);
    await prefs.remove(_categoriesPrefsKey);
  }

  @override
  Future<List<TranslationHistoryItem>> loadHistory() async {
    final database = await _open();
    final rows = await database.query('history', orderBy: 'timestamp DESC');
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> saveHistory(List<TranslationHistoryItem> items) async {
    final database = await _open();
    await database.transaction((txn) async {
      await txn.delete('history');
      for (final item in items) {
        await txn.insert('history', _toRow(item));
      }
    });
  }

  @override
  Future<List<String>> loadCategories() async {
    final database = await _open();
    final rows = await database.query('categories', orderBy: 'position ASC');
    return rows.map((row) => row['name'] as String).toList();
  }

  @override
  Future<void> saveCategories(List<String> categories) async {
    final database = await _open();
    await database.transaction((txn) async {
      await txn.delete('categories');
      for (var i = 0; i < categories.length; i++) {
        await txn.insert('categories', {'position': i, 'name': categories[i]});
      }
    });
  }

  Map<String, Object> _toRow(TranslationHistoryItem item) {
    return {
      'id': item.id,
      'source_text': item.sourceText,
      'translated_text': item.translatedText,
      'source_language_code': item.sourceLanguageCode,
      'source_language_name': item.sourceLanguageName,
      'source_language_flag': item.sourceLanguageFlag,
      'target_language_code': item.targetLanguageCode,
      'target_language_name': item.targetLanguageName,
      'target_language_flag': item.targetLanguageFlag,
      'timestamp': item.timestamp.millisecondsSinceEpoch,
      'is_favorite': item.isFavorite ? 1 : 0,
      'category': item.category,
    };
  }

  TranslationHistoryItem _fromRow(Map<String, Object?> row) {
    return TranslationHistoryItem(
      id: row['id'] as String? ?? '',
      sourceText: row['source_text'] as String? ?? '',
      translatedText: row['translated_text'] as String? ?? '',
      sourceLanguageCode: row['source_language_code'] as String? ?? 'en',
      sourceLanguageName: row['source_language_name'] as String? ?? 'English',
      sourceLanguageFlag: row['source_language_flag'] as String? ?? '',
      targetLanguageCode: row['target_language_code'] as String? ?? 'es',
      targetLanguageName: row['target_language_name'] as String? ?? 'Spanish',
      targetLanguageFlag: row['target_language_flag'] as String? ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (row['timestamp'] as int?) ?? 0,
      ),
      isFavorite: (row['is_favorite'] as int? ?? 0) == 1,
      category: row['category'] as String? ?? 'General',
    );
  }
}
