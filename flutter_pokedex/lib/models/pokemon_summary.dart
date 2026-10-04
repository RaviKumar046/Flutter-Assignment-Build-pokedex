class PokemonSummary {
  const PokemonSummary({required this.id, required this.name, this.apiUrl});

  final int id;
  final String name;
  final String? apiUrl;

  String get artworkUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/'
      'sprites/pokemon/other/official-artwork/$id.png';

  factory PokemonSummary.fromApiJson(Map<String, dynamic> json) {
    final name = json['name'];
    final url = json['url'];
    if (name is! String || name.trim().isEmpty || url is! String) {
      throw const FormatException(
        'A Pokémon result is missing its name or URL.',
      );
    }

    final id = _idFromUrl(url);
    if (id == null || id <= 0) {
      throw const FormatException('A Pokémon result has an invalid URL.');
    }

    return PokemonSummary(id: id, name: name.trim(), apiUrl: url);
  }

  factory PokemonSummary.fromFavoriteJson(Map<String, dynamic> json) {
    final idValue = json['id'];
    final nameValue = json['name'];
    final id = idValue is int ? idValue : int.tryParse('$idValue');
    if (id == null || id <= 0 || nameValue is! String || nameValue.isEmpty) {
      throw const FormatException('A saved favorite is invalid.');
    }
    return PokemonSummary(id: id, name: nameValue);
  }

  Map<String, Object> toFavoriteJson() => {'id': id, 'name': name};

  static int? _idFromUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return null;

    for (final segment in uri.pathSegments.reversed) {
      if (segment.isEmpty) continue;
      final id = int.tryParse(segment);
      if (id != null) return id;
    }
    return null;
  }
}

class PokemonPage {
  const PokemonPage({required this.results, required this.nextUrl});

  final List<PokemonSummary> results;
  final String? nextUrl;

  factory PokemonPage.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'];
    final results = <PokemonSummary>[];
    if (rawResults is List) {
      for (final item in rawResults) {
        if (item is! Map) continue;
        try {
          results.add(
            PokemonSummary.fromApiJson(Map<String, dynamic>.from(item)),
          );
        } on FormatException {
          // Ignore malformed rows without discarding valid results.
        }
      }
    }

    final nextValue = json['next'];
    return PokemonPage(
      results: results,
      nextUrl: nextValue is String && nextValue.isNotEmpty ? nextValue : null,
    );
  }
}
