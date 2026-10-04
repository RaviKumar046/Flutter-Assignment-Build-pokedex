import 'package:flutter/material.dart';

import '../utils/pokedex_style.dart';

class PokemonTypePill extends StatelessWidget {
  const PokemonTypePill({super.key, required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: PokedexStyle.typeColor(type),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Text(
          PokedexStyle.titleCase(type),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
