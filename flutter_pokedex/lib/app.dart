import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/favorites_provider.dart';
import 'providers/pokemon_provider.dart';
import 'screens/home_screen.dart';
import 'services/pokemon_api.dart';
import 'utils/pokedex_style.dart';

class PokedexApp extends StatelessWidget {
  const PokedexApp({
    super.key,
    required this.api,
    required this.favoritesProvider,
  });

  final PokemonApi api;
  final FavoritesProvider favoritesProvider;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: PokedexStyle.red,
      brightness: Brightness.light,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FavoritesProvider>.value(
          value: favoritesProvider,
        ),
        ChangeNotifierProvider(create: (_) => PokemonProvider(api)),
      ],
      child: MaterialApp(
        title: 'Pokédex',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: colorScheme,
          scaffoldBackgroundColor: PokedexStyle.canvas,
          appBarTheme: const AppBarTheme(
            backgroundColor: PokedexStyle.canvas,
            foregroundColor: PokedexStyle.ink,
            centerTitle: false,
            elevation: 0,
          ),
          textTheme: ThemeData.light().textTheme.apply(
            bodyColor: PokedexStyle.ink,
            displayColor: PokedexStyle.ink,
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: Colors.white,
            indicatorColor: PokedexStyle.red.withValues(alpha: 0.12),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              return TextStyle(
                fontWeight: states.contains(WidgetState.selected)
                    ? FontWeight.w700
                    : FontWeight.w500,
                fontSize: 12,
              );
            }),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            hintStyle: const TextStyle(color: PokedexStyle.muted),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: PokedexStyle.darkRed,
                width: 2,
              ),
            ),
          ),
        ),
        home: const PokedexHomeScreen(),
      ),
    );
  }
}
