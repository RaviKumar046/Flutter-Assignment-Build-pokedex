import 'package:flutter/foundation.dart';

import '../models/pokemon_detail.dart';
import '../models/pokemon_summary.dart';
import '../services/pokemon_api.dart';

class PokemonProvider extends ChangeNotifier {
  PokemonProvider(this._api);

  final PokemonApi _api;
  final List<PokemonSummary> _pokemon = [];
  final Map<int, PokemonDetail> _details = {};
  final Map<int, Future<PokemonDetail>> _detailRequests = {};

  String? _nextUrl;
  String? _errorMessage;
  String? _paginationError;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasLoaded = false;

  List<PokemonSummary> get pokemon => List.unmodifiable(_pokemon);
  String? get errorMessage => _errorMessage;
  String? get paginationError => _paginationError;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasLoaded => _hasLoaded;
  bool get hasMore => _nextUrl != null;

  List<PokemonSummary> search(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return pokemon;
    return _pokemon
        .where((item) => item.name.toLowerCase().contains(normalized))
        .toList(growable: false);
  }

  Future<void> loadInitial({bool retry = false}) async {
    if (_isLoading || (_hasLoaded && !retry)) return;

    _isLoading = true;
    _errorMessage = null;
    _paginationError = null;
    if (retry) {
      _pokemon.clear();
      _nextUrl = null;
      _hasLoaded = false;
    }
    notifyListeners();

    try {
      final page = await _api.fetchPage();
      _pokemon
        ..clear()
        ..addAll(_uniqueResults(page.results));
      _nextUrl = page.nextUrl;
      _hasLoaded = true;
    } catch (error) {
      _errorMessage = _userMessage(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNextPage() async {
    final url = _nextUrl;
    if (url == null || _isLoading || _isLoadingMore) return;

    _isLoadingMore = true;
    _paginationError = null;
    notifyListeners();

    try {
      final page = await _api.fetchPage(url: url);
      final knownIds = _pokemon.map((item) => item.id).toSet();
      for (final item in page.results) {
        if (knownIds.add(item.id)) _pokemon.add(item);
      }
      _nextUrl = page.nextUrl;
    } catch (error) {
      _paginationError = _userMessage(error);
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<PokemonDetail> fetchDetails(PokemonSummary pokemon) {
    final cached = _details[pokemon.id];
    if (cached != null) return Future.value(cached);

    final activeRequest = _detailRequests[pokemon.id];
    if (activeRequest != null) return activeRequest;

    final request = _api
        .fetchDetails(pokemon)
        .then((detail) {
          _details[pokemon.id] = detail;
          return detail;
        })
        .whenComplete(() {
          _detailRequests.remove(pokemon.id);
        });
    _detailRequests[pokemon.id] = request;
    return request;
  }

  List<PokemonSummary> _uniqueResults(List<PokemonSummary> results) {
    final seen = <int>{};
    return results.where((item) => seen.add(item.id)).toList(growable: false);
  }

  String _userMessage(Object error) {
    if (error is PokemonApiException) return error.message;
    return 'Something went wrong. Please try again.';
  }
}
