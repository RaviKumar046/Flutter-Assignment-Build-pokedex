import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pokedex/models/pokemon_summary.dart';
import 'package:flutter_pokedex/providers/favorites_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loads and persists favorite references locally', () async {
    final provider = FavoritesProvider();
    await provider.load();

    const pikachu = PokemonSummary(id: 25, name: 'pikachu');
    await provider.toggle(pikachu);

    expect(provider.isFavorite(25), isTrue);
    expect(provider.favorites.single.name, 'pikachu');

    final preferences = await SharedPreferences.getInstance();
    final saved = jsonDecode(preferences.getString('favorite_pokemon_v1')!);
    expect(saved, [
      {'id': 25, 'name': 'pikachu'},
    ]);

    final restoredProvider = FavoritesProvider();
    await restoredProvider.load();
    expect(restoredProvider.isFavorite(25), isTrue);
    expect(restoredProvider.favorites.single.name, 'pikachu');
  });

  test('rapid toggles leave the latest state persisted', () async {
    final provider = FavoritesProvider();
    await provider.load();
    const pikachu = PokemonSummary(id: 25, name: 'pikachu');

    final firstToggle = provider.toggle(pikachu);
    final secondToggle = provider.toggle(pikachu);
    await Future.wait([firstToggle, secondToggle]);

    expect(provider.isFavorite(25), isFalse);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('favorite_pokemon_v1'), '[]');
  });
}
