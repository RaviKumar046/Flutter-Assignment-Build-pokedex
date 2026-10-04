import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pokedex/models/pokemon_detail.dart';
import 'package:flutter_pokedex/models/pokemon_summary.dart';

void main() {
  group('PokemonSummary', () {
    test('extracts its ID from a trailing-slash PokéAPI URL', () {
      final pokemon = PokemonSummary.fromApiJson({
        'name': 'pikachu',
        'url': 'https://pokeapi.co/api/v2/pokemon/25/',
      });

      expect(pokemon.id, 25);
      expect(pokemon.name, 'pikachu');
      expect(pokemon.artworkUrl, contains('/25.png'));
    });

    test('rejects a result without a usable ID', () {
      expect(
        () => PokemonSummary.fromApiJson({
          'name': 'pikachu',
          'url': 'https://pokeapi.co/api/v2/pokemon/unknown/',
        }),
        throwsFormatException,
      );
    });
  });

  test('parses detail data with safe fallbacks', () {
    final detail = PokemonDetail.fromJson({
      'id': 25,
      'name': 'pikachu',
      'height': 4,
      'weight': 60,
      'sprites': {
        'front_default': 'https://example.com/pikachu.png',
        'other': {
          'official-artwork': {
            'front_default': 'https://example.com/pikachu-art.png',
          },
        },
      },
      'types': [
        {
          'type': {'name': 'electric'},
        },
      ],
      'abilities': [
        {
          'ability': {'name': 'static'},
        },
      ],
      'stats': [
        {
          'base_stat': 35,
          'stat': {'name': 'hp'},
        },
      ],
    });

    expect(detail.artworkUrl, 'https://example.com/pikachu-art.png');
    expect(detail.types, ['electric']);
    expect(detail.abilities, ['static']);
    expect(detail.stats.single.baseStat, 35);
    expect(detail.heightInMeters, '0.4');
    expect(detail.weightInKilograms, '6.0');
  });
}
