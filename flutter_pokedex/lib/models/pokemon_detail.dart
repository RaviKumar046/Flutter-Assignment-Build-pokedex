class PokemonDetail {
  const PokemonDetail({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.types,
    required this.abilities,
    required this.stats,
    this.artworkUrl,
  });

  final int id;
  final String name;
  final int height;
  final int weight;
  final List<String> types;
  final List<String> abilities;
  final List<PokemonStat> stats;
  final String? artworkUrl;

  String get heightInMeters => (height / 10).toStringAsFixed(1);
  String get weightInKilograms => (weight / 10).toStringAsFixed(1);

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    final sprites = _asMap(json['sprites']);
    final other = _asMap(sprites['other']);
    final officialArtwork = _asMap(other['official-artwork']);
    final artwork =
        _asString(officialArtwork['front_default']) ??
        _asString(sprites['front_default']);

    final types = <String>[];
    final rawTypes = json['types'];
    if (rawTypes is List) {
      for (final entry in rawTypes) {
        if (entry is! Map) continue;
        final name = _asString(_asMap(_asMap(entry)['type'])['name']);
        if (name != null && name.isNotEmpty) types.add(name);
      }
    }

    final abilities = <String>[];
    final rawAbilities = json['abilities'];
    if (rawAbilities is List) {
      for (final entry in rawAbilities) {
        if (entry is! Map) continue;
        final name = _asString(_asMap(_asMap(entry)['ability'])['name']);
        if (name != null && name.isNotEmpty) abilities.add(name);
      }
    }

    final stats = <PokemonStat>[];
    final rawStats = json['stats'];
    if (rawStats is List) {
      for (final entry in rawStats) {
        if (entry is! Map) continue;
        final stat = _asMap(entry);
        final statName = _asString(_asMap(stat['stat'])['name']);
        final baseStat = _asInt(stat['base_stat']);
        if (statName != null && baseStat != null) {
          stats.add(PokemonStat(name: statName, baseStat: baseStat));
        }
      }
    }

    return PokemonDetail(
      id: _asInt(json['id']) ?? 0,
      name: _asString(json['name']) ?? 'unknown',
      height: _asInt(json['height']) ?? 0,
      weight: _asInt(json['weight']) ?? 0,
      types: types,
      abilities: abilities,
      stats: stats,
      artworkUrl: artwork,
    );
  }
}

class PokemonStat {
  const PokemonStat({required this.name, required this.baseStat});

  final String name;
  final int baseStat;
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

String? _asString(Object? value) => value is String ? value : null;

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value');
}
