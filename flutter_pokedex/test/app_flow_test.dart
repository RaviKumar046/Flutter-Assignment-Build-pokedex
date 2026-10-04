import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pokedex/app.dart';
import 'package:flutter_pokedex/providers/favorites_provider.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_pokemon_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'favorite state stays synchronized across list, detail, and favorites',
    (tester) async {
      await mockNetworkImagesFor(() async {
        SharedPreferences.setMockInitialValues({});
        final favorites = FavoritesProvider();
        await favorites.load();

        await tester.pumpWidget(
          PokedexApp(api: FakePokemonApi(), favoritesProvider: favorites),
        );
        await tester.pumpAndSettle();

        expect(find.text('Pikachu'), findsOneWidget);
        await tester.tap(find.byTooltip('Add Pikachu to favorites'));
        await tester.pumpAndSettle();
        expect(find.byTooltip('Remove Pikachu from favorites'), findsOneWidget);

        await tester.tap(find.text('Pikachu').first);
        await tester.pumpAndSettle();
        expect(find.text('Height'), findsOneWidget);
        expect(find.byTooltip('Remove Pikachu from favorites'), findsOneWidget);

        await tester.tap(find.byTooltip('Remove Pikachu from favorites'));
        await tester.pumpAndSettle();
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.byTooltip('Add Pikachu to favorites'), findsOneWidget);

        await tester.tap(find.byTooltip('Add Pikachu to favorites'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Favorites'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Pikachu'), findsOneWidget);
        await tester.tap(find.byTooltip('Remove Pikachu from favorites'));
        await tester.pumpAndSettle();
        expect(find.text('No favorite Pokémon yet'), findsOneWidget);
      });
    },
  );
}
