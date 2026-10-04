import 'package:flutter/material.dart';

import 'app.dart';
import 'providers/favorites_provider.dart';
import 'services/pokemon_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final favoritesProvider = FavoritesProvider();
  await favoritesProvider.load();

  runApp(
    PokedexApp(api: PokemonApiService(), favoritesProvider: favoritesProvider),
  );
}
