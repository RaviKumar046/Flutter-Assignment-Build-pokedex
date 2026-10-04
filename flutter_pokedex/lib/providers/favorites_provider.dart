import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pokemon_summary.dart';

class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider({Future<SharedPreferences> Function()? preferencesLoader})
    : _preferencesLoader = preferencesLoader ?? SharedPreferences.getInstance;

  static const _storageKey = 'favorite_pokemon_v1';
  final Future<SharedPreferences> Function() _preferencesLoader;
  final Map<int, PokemonSummary> _favorites = {};

  Future<void> _writeQueue = Future<void>.value();
  bool _isInitialized = false;
  String? _storageWarning;

  bool get isInitialized => _isInitialized;
  String? get storageWarning => _storageWarning;
  int get count => _favorites.length;

  List<PokemonSummary> get favorites {
    final result = _favorites.values.toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    return List.unmodifiable(result);
  }

  bool isFavorite(int pokemonId) => _favorites.containsKey(pokemonId);

  Future<void> load() async {
    if (_isInitialized) return;
    try {
      final preferences = await _preferencesLoader();
      final saved = preferences.getString(_storageKey);
      if (saved != null && saved.isNotEmpty) {
        final decoded = jsonDecode(saved);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is! Map) continue;
            try {
              final pokemon = PokemonSummary.fromFavoriteJson(
                Map<String, dynamic>.from(item),
              );
              _favorites[pokemon.id] = pokemon;
            } on FormatException {
              // Skip one damaged entry but keep any valid saved favorites.
            }
          }
        }
      }
    } catch (_) {
      _storageWarning = 'Saved favorites could not be loaded on this device.';
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> toggle(PokemonSummary pokemon) async {
    if (_favorites.containsKey(pokemon.id)) {
      _favorites.remove(pokemon.id);
    } else {
      _favorites[pokemon.id] = PokemonSummary(
        id: pokemon.id,
        name: pokemon.name,
      );
    }

    _storageWarning = null;
    notifyListeners();
    _scheduleWrite();
    await _writeQueue;
  }

  void _scheduleWrite() {
    final snapshot = favorites.map((item) => item.toFavoriteJson()).toList();
    _writeQueue = _writeQueue
        .then<void>((_) async {
          final preferences = await _preferencesLoader();
          final stored = await preferences.setString(
            _storageKey,
            jsonEncode(snapshot),
          );
          if (!stored) {
            throw StateError('SharedPreferences rejected the write.');
          }
        })
        .catchError((Object _) {
          _storageWarning =
              'A favorite changed, but could not be saved locally.';
          notifyListeners();
        });
  }
}
