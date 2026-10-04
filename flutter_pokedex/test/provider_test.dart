import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pokedex/providers/pokemon_provider.dart';

import 'fakes/fake_pokemon_api.dart';

void main() {
  test('pagination appends new Pokémon and skips duplicate IDs', () async {
    final provider = PokemonProvider(
      FakePokemonApi(nextUrl: FakePokemonApi.paginationUrl),
    );

    await provider.loadInitial();
    expect(provider.pokemon.map((item) => item.id), [25, 1]);

    await provider.loadNextPage();
    expect(provider.pokemon.map((item) => item.id), [25, 1, 2]);
    expect(provider.hasMore, isFalse);
  });

  test('initial load exposes an error and retry recovers', () async {
    final provider = PokemonProvider(FakePokemonApi(initialPageErrorCount: 1));

    await provider.loadInitial();
    expect(provider.errorMessage, 'Temporary network error.');
    expect(provider.pokemon, isEmpty);

    await provider.loadInitial(retry: true);
    expect(provider.errorMessage, isNull);
    expect(provider.pokemon, hasLength(2));
  });
}
