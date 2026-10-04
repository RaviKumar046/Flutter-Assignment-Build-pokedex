import 'package:flutter/material.dart';

import '../models/pokemon_summary.dart';
import '../utils/pokedex_style.dart';
import 'favorite_button.dart';
import 'pokemon_artwork.dart';

class PokemonCard extends StatelessWidget {
  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
  });

  final PokemonSummary pokemon;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final readableName = PokedexStyle.titleCase(pokemon.name);

    return Material(
      color: PokedexStyle.cardColor(pokemon.id),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${pokemon.id.toString().padLeft(3, '0')}',
                    style: const TextStyle(
                      color: PokedexStyle.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: PokemonArtwork(
                        imageUrl: pokemon.artworkUrl,
                        name: readableName,
                        size: 112,
                      ),
                    ),
                  ),
                  Text(
                    readableName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: PokedexStyle.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Pokémon',
                    style: TextStyle(color: PokedexStyle.muted, fontSize: 11),
                  ),
                ],
              ),
              Positioned(
                top: -8,
                right: -8,
                child: FavoriteButton(
                  name: pokemon.name,
                  isFavorite: isFavorite,
                  onPressed: onFavoriteTap,
                  iconSize: 19,
                ),
              ),
              Positioned(
                right: 2,
                bottom: 1,
                child: Icon(
                  Icons.catching_pokemon,
                  size: 48,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
