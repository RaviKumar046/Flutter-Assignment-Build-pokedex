import 'package:flutter/material.dart';

import '../models/pokemon_detail.dart';
import '../utils/pokedex_style.dart';

class StatBar extends StatelessWidget {
  const StatBar({super.key, required this.stat});

  final PokemonStat stat;

  @override
  Widget build(BuildContext context) {
    final value = (stat.baseStat / 180).clamp(0.0, 1.0).toDouble();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          SizedBox(
            width: 116,
            child: Text(
              PokedexStyle.titleCase(stat.name),
              style: const TextStyle(
                color: PokedexStyle.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 30,
            child: Text(
              '${stat.baseStat}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                minHeight: 7,
                value: value,
                backgroundColor: const Color(0xFFEEF0F5),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  PokedexStyle.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
