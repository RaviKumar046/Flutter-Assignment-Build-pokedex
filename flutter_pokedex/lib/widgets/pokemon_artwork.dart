import 'package:flutter/material.dart';

class PokemonArtwork extends StatelessWidget {
  const PokemonArtwork({
    super.key,
    required this.imageUrl,
    required this.name,
    this.size = 112,
  });

  final String imageUrl;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      semanticLabel: '$name artwork',
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.catching_pokemon,
        size: size * 0.72,
        color: Colors.black26,
      ),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          width: size,
          height: size,
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: progress.expectedTotalBytes == null
                    ? null
                    : progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!,
              ),
            ),
          ),
        );
      },
    );
  }
}
