import 'package:flutter/material.dart';

class PokedexStyle {
  static const ink = Color(0xFF202332);
  static const muted = Color(0xFF85899A);
  static const canvas = Color(0xFFF6F7FB);
  static const red = Color(0xFFE94F4F);
  static const darkRed = Color(0xFFC83C47);
  static const cardColors = <Color>[
    Color(0xFFFFE7DE),
    Color(0xFFE2F1F3),
    Color(0xFFE7F2DA),
    Color(0xFFECE5FA),
    Color(0xFFFFF0CE),
    Color(0xFFE1E9FC),
  ];

  static Color cardColor(int id) =>
      cardColors[(id - 1).abs() % cardColors.length];

  static Color typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return const Color(0xFFEF765A);
      case 'water':
        return const Color(0xFF6394E8);
      case 'grass':
        return const Color(0xFF64B37B);
      case 'electric':
        return const Color(0xFFE2B94E);
      case 'ice':
        return const Color(0xFF70C7D3);
      case 'fighting':
        return const Color(0xFFC85B61);
      case 'poison':
        return const Color(0xFF9B69C9);
      case 'ground':
        return const Color(0xFFC49558);
      case 'flying':
        return const Color(0xFF8C9CE1);
      case 'psychic':
        return const Color(0xFFE76A9C);
      case 'bug':
        return const Color(0xFF8AA447);
      case 'rock':
        return const Color(0xFFA59463);
      case 'ghost':
        return const Color(0xFF7766A5);
      case 'dragon':
        return const Color(0xFF6C77D2);
      case 'dark':
        return const Color(0xFF68636E);
      case 'steel':
        return const Color(0xFF8A9DA9);
      case 'fairy':
        return const Color(0xFFDB83AC);
      default:
        return const Color(0xFF9298A7);
    }
  }

  static String titleCase(String value) {
    return value
        .replaceAll('-', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
