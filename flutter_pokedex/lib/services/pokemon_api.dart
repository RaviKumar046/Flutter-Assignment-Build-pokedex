import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pokemon_detail.dart';
import '../models/pokemon_summary.dart';

abstract interface class PokemonApi {
  Future<PokemonPage> fetchPage({String? url});

  Future<PokemonDetail> fetchDetails(PokemonSummary pokemon);
}

class PokemonApiService implements PokemonApi {
  PokemonApiService({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = 'https://pokeapi.co/api/v2';
  static const _pageSize = 20;
  static const _requestTimeout = Duration(seconds: 18);

  final http.Client _client;

  @override
  Future<PokemonPage> fetchPage({String? url}) async {
    final uri = _validatedUri(
      url ?? '$_baseUrl/pokemon?limit=$_pageSize&offset=0',
    );
    final json = await _getJson(uri);
    return PokemonPage.fromJson(json);
  }

  @override
  Future<PokemonDetail> fetchDetails(PokemonSummary pokemon) async {
    final uri = Uri.parse('$_baseUrl/pokemon/${pokemon.id}');
    final json = await _getJson(uri);
    final detail = PokemonDetail.fromJson(json);
    if (detail.id <= 0) {
      throw const PokemonApiException('The Pokémon details were incomplete.');
    }
    return detail;
  }

  Uri _validatedUri(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host != 'pokeapi.co' ||
        !uri.path.startsWith('/api/v2/pokemon')) {
      throw const PokemonApiException('PokéAPI returned an invalid page link.');
    }
    return uri;
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    late final http.Response response;
    try {
      response = await _client.get(uri).timeout(_requestTimeout);
    } on TimeoutException {
      throw const PokemonApiException(
        'The request took too long. Check your connection and try again.',
      );
    } on http.ClientException {
      throw const PokemonApiException(
        'Could not reach PokéAPI. Check your connection and try again.',
      );
    } catch (_) {
      throw const PokemonApiException(
        'Could not reach PokéAPI. Check your connection and try again.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PokemonApiException(
        'PokéAPI returned an error (${response.statusCode}). Please retry.',
      );
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        throw const FormatException('Expected a JSON object.');
      }
      return Map<String, dynamic>.from(decoded);
    } on FormatException {
      throw const PokemonApiException(
        'PokéAPI returned data that could not be read. Please retry.',
      );
    }
  }
}

class PokemonApiException implements Exception {
  const PokemonApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
