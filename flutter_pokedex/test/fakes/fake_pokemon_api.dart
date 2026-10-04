import 'package:flutter_pokedex/models/pokemon_detail.dart';
import 'package:flutter_pokedex/models/pokemon_summary.dart';
import 'package:flutter_pokedex/services/pokemon_api.dart';

class FakePokemonApi implements PokemonApi {
  FakePokemonApi({this.nextUrl, this.initialPageErrorCount = 0});

  static const paginationUrl =
      'https://pokeapi.co/api/v2/pokemon?offset=40&limit=20';

  final String? nextUrl;
  int initialPageErrorCount;
  int pageRequestCount = 0;

  static const firstResults = [
    PokemonSummary(id: 25, name: 'pikachu'),
    PokemonSummary(id: 1, name: 'bulbasaur'),
  ];

  static const secondResults = [
    PokemonSummary(id: 1, name: 'bulbasaur'),
    PokemonSummary(id: 2, name: 'ivysaur'),
  ];

  @override
  Future<PokemonPage> fetchPage({String? url}) async {
    pageRequestCount++;
    if (url == null && initialPageErrorCount > 0) {
      initialPageErrorCount--;
      throw const PokemonApiException('Temporary network error.');
    }

    if (url == null) {
      return PokemonPage(results: firstResults, nextUrl: nextUrl);
    }
    return const PokemonPage(results: secondResults, nextUrl: null);
  }

  @override
  Future<PokemonDetail> fetchDetails(PokemonSummary pokemon) async {
    return PokemonDetail(
      id: pokemon.id,
      name: pokemon.name,
      height: 4,
      weight: 60,
      types: const ['electric'],
      abilities: const ['static', 'lightning-rod'],
      stats: const [
        PokemonStat(name: 'hp', baseStat: 35),
        PokemonStat(name: 'attack', baseStat: 55),
        PokemonStat(name: 'defense', baseStat: 40),
        PokemonStat(name: 'special-attack', baseStat: 50),
        PokemonStat(name: 'special-defense', baseStat: 50),
        PokemonStat(name: 'speed', baseStat: 90),
      ],
    );
  }
}
