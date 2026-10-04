import 'package:flutter/material.dart';

import '../utils/pokedex_style.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.name,
    required this.isFavorite,
    required this.onPressed,
    this.iconSize = 22,
  });

  final String name;
  final bool isFavorite;
  final VoidCallback onPressed;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final readableName = PokedexStyle.titleCase(name);
    return IconButton(
      tooltip: isFavorite
          ? 'Remove $readableName from favorites'
          : 'Add $readableName to favorites',
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.94),
        foregroundColor: isFavorite ? PokedexStyle.red : PokedexStyle.muted,
        minimumSize: const Size(42, 42),
      ),
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        size: iconSize,
      ),
    );
  }
}
