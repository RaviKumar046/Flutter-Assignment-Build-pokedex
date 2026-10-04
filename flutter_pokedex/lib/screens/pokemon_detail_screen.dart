import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pokemon_detail.dart';
import '../models/pokemon_summary.dart';
import '../providers/favorites_provider.dart';
import '../providers/pokemon_provider.dart';
import '../utils/pokedex_style.dart';
import '../widgets/favorite_button.dart';
import '../widgets/pokemon_artwork.dart';
import '../widgets/pokemon_type_pill.dart';
import '../widgets/stat_bar.dart';
import '../widgets/status_panel.dart';

class PokemonDetailScreen extends StatefulWidget {
  const PokemonDetailScreen({super.key, required this.pokemon});

  final PokemonSummary pokemon;

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  late Future<PokemonDetail> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = context.read<PokemonProvider>().fetchDetails(
      widget.pokemon,
    );
  }

  void _retry() {
    setState(() {
      _detailFuture = context.read<PokemonProvider>().fetchDetails(
        widget.pokemon,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final isFavorite = favorites.isFavorite(widget.pokemon.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(PokedexStyle.titleCase(widget.pokemon.name)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FavoriteButton(
              name: widget.pokemon.name,
              isFavorite: isFavorite,
              onPressed: () =>
                  context.read<FavoritesProvider>().toggle(widget.pokemon),
            ),
          ),
        ],
      ),
      body: FutureBuilder<PokemonDetail>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: PokedexStyle.red),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return StatusPanel(
              icon: Icons.cloud_off_rounded,
              title: 'Details are unavailable',
              message:
                  snapshot.error?.toString() ??
                  'PokéAPI did not return details for this Pokémon.',
              actionLabel: 'Retry',
              onAction: _retry,
            );
          }
          return _DetailContent(
            summary: widget.pokemon,
            detail: snapshot.data!,
          );
        },
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.summary, required this.detail});

  final PokemonSummary summary;
  final PokemonDetail detail;

  @override
  Widget build(BuildContext context) {
    final accent = detail.types.isEmpty
        ? PokedexStyle.red
        : PokedexStyle.typeColor(detail.types.first);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _DetailHero(summary: summary, detail: detail, accent: accent),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const _SectionHeading(title: 'About'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MeasureCard(
                      icon: Icons.height_rounded,
                      label: 'Height',
                      value: detail.heightInMeters,
                      unit: 'm',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MeasureCard(
                      icon: Icons.monitor_weight_outlined,
                      label: 'Weight',
                      value: detail.weightInKilograms,
                      unit: 'kg',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const _SectionHeading(title: 'Types'),
              const SizedBox(height: 12),
              if (detail.types.isEmpty)
                const Text(
                  'No type information available.',
                  style: TextStyle(color: PokedexStyle.muted),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: detail.types
                      .map((type) => PokemonTypePill(type: type))
                      .toList(),
                ),
              const SizedBox(height: 24),
              const _SectionHeading(title: 'Abilities'),
              const SizedBox(height: 12),
              if (detail.abilities.isEmpty)
                const Text(
                  'No ability information available.',
                  style: TextStyle(color: PokedexStyle.muted),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: detail.abilities
                      .map(
                        (ability) => Chip(
                          label: Text(PokedexStyle.titleCase(ability)),
                          backgroundColor: Colors.white,
                          side: BorderSide.none,
                          labelStyle: const TextStyle(
                            color: PokedexStyle.ink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 24),
              const _SectionHeading(title: 'Base stats'),
              const SizedBox(height: 12),
              if (detail.stats.isEmpty)
                const Text(
                  'No base stats available.',
                  style: TextStyle(color: PokedexStyle.muted),
                )
              else
                ...detail.stats.map((stat) => StatBar(stat: stat)),
            ]),
          ),
        ),
      ],
    );
  }
}

class _DetailHero extends StatelessWidget {
  const _DetailHero({
    required this.summary,
    required this.detail,
    required this.accent,
  });

  final PokemonSummary summary;
  final PokemonDetail detail;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final imageUrl = detail.artworkUrl ?? summary.artworkUrl;
    final readableName = PokedexStyle.titleCase(detail.name);

    return Container(
      height: 286,
      margin: const EdgeInsets.fromLTRB(18, 4, 18, 0),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: -16,
            top: -22,
            child: Icon(
              Icons.catching_pokemon,
              size: 180,
              color: accent.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            left: 22,
            top: 22,
            child: Text(
              '#${detail.id.toString().padLeft(3, '0')}',
              style: TextStyle(
                color: accent,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Positioned(
            left: 22,
            bottom: 24,
            right: 22,
            child: Text(
              readableName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: PokedexStyle.ink,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Positioned(
            top: 24,
            right: 22,
            child: Wrap(
              spacing: 6,
              children: detail.types
                  .map((type) => PokemonTypePill(type: type))
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 22),
            child: PokemonArtwork(
              imageUrl: imageUrl,
              name: readableName,
              size: 210,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: PokedexStyle.ink,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _MeasureCard extends StatelessWidget {
  const _MeasureCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
  });

  final IconData icon;
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: PokedexStyle.red),
              const SizedBox(width: 7),
              Text(
                label,
                style: const TextStyle(
                  color: PokedexStyle.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              text: value,
              style: const TextStyle(
                color: PokedexStyle.ink,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
              children: [
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    color: PokedexStyle.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
