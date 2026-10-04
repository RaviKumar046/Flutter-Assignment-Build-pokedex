import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pokemon_summary.dart';
import '../providers/favorites_provider.dart';
import '../providers/pokemon_provider.dart';
import '../utils/pokedex_style.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/status_panel.dart';
import 'pokemon_detail_screen.dart';

class PokedexHomeScreen extends StatefulWidget {
  const PokedexHomeScreen({super.key});

  @override
  State<PokedexHomeScreen> createState() => _PokedexHomeScreenState();
}

class _PokedexHomeScreenState extends State<PokedexHomeScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();

    return Scaffold(
      body: IndexedStack(
        index: _selectedTab,
        children: const [PokemonListScreen(), FavoritesScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) => setState(() => _selectedTab = index),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.catching_pokemon_outlined),
            selectedIcon: Icon(Icons.catching_pokemon),
            label: 'Pokédex',
          ),
          NavigationDestination(
            icon: _FavoriteTabIcon(count: favorites.count, selected: false),
            selectedIcon: _FavoriteTabIcon(
              count: favorites.count,
              selected: true,
            ),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}

class _FavoriteTabIcon extends StatelessWidget {
  const _FavoriteTabIcon({required this.count, required this.selected});

  final int count;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(selected ? Icons.favorite : Icons.favorite_border);
    if (count == 0) return icon;
    return Badge(label: Text('$count'), child: icon);
  }
}

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key});

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<PokemonProvider>().loadInitial();
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _query.trim().isNotEmpty) return;
    if (_scrollController.position.extentAfter < 420) {
      context.read<PokemonProvider>().loadNextPage();
    }
  }

  void _openDetails(PokemonSummary pokemon) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PokemonDetailScreen(pokemon: pokemon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pokemonProvider = context.watch<PokemonProvider>();
    final favorites = context.watch<FavoritesProvider>();
    final results = pokemonProvider.search(_query);

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760
            ? 4
            : constraints.maxWidth >= 520
            ? 3
            : 2;

        return CustomScrollView(
          controller: _scrollController,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: _ListHeader(
                controller: _searchController,
                loadedCount: pokemonProvider.pokemon.length,
                query: _query,
                onChanged: (value) => setState(() => _query = value),
                onClear: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
                child: Row(
                  children: [
                    Text(
                      _query.trim().isEmpty ? 'DISCOVER' : 'SEARCH RESULTS',
                      style: const TextStyle(
                        color: PokedexStyle.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${results.length} loaded',
                      style: const TextStyle(
                        color: PokedexStyle.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (pokemonProvider.isLoading && pokemonProvider.pokemon.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: StatusPanel(
                  icon: Icons.catching_pokemon,
                  title: 'Finding Pokémon',
                  message: 'Connecting to PokéAPI to load your Pokédex.',
                  compact: true,
                ),
              )
            else if (pokemonProvider.errorMessage != null &&
                pokemonProvider.pokemon.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: StatusPanel(
                  icon: Icons.wifi_off_rounded,
                  title: 'Could not load Pokémon',
                  message: pokemonProvider.errorMessage!,
                  actionLabel: 'Retry',
                  onAction: () =>
                      context.read<PokemonProvider>().loadInitial(retry: true),
                ),
              )
            else if (results.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: StatusPanel(
                  icon: _query.trim().isEmpty
                      ? Icons.catching_pokemon_outlined
                      : Icons.search_off_rounded,
                  title: _query.trim().isEmpty
                      ? 'No Pokémon found'
                      : 'No matches yet',
                  message: _query.trim().isEmpty
                      ? 'PokéAPI returned an empty page.'
                      : 'Search checks the Pokémon loaded so far.',
                  actionLabel:
                      _query.trim().isNotEmpty && pokemonProvider.hasMore
                      ? 'Load more Pokémon'
                      : null,
                  onAction: _query.trim().isNotEmpty && pokemonProvider.hasMore
                      ? () => context.read<PokemonProvider>().loadNextPage()
                      : null,
                  compact: true,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 13,
                    mainAxisSpacing: 13,
                    mainAxisExtent: 205,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final pokemon = results[index];
                    return PokemonCard(
                      pokemon: pokemon,
                      isFavorite: favorites.isFavorite(pokemon.id),
                      onTap: () => _openDetails(pokemon),
                      onFavoriteTap: () {
                        context.read<FavoritesProvider>().toggle(pokemon);
                      },
                    );
                  }, childCount: results.length),
                ),
              ),
            if (pokemonProvider.paginationError != null)
              SliverToBoxAdapter(
                child: _PaginationMessage(
                  message: pokemonProvider.paginationError!,
                  actionLabel: 'Retry loading more',
                  onPressed: () =>
                      context.read<PokemonProvider>().loadNextPage(),
                ),
              )
            else if (pokemonProvider.isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: SizedBox(
                      height: 26,
                      width: 26,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
                ),
              )
            else if (_query.trim().isEmpty &&
                pokemonProvider.hasMore &&
                pokemonProvider.pokemon.isNotEmpty)
              SliverToBoxAdapter(
                child: _PaginationMessage(
                  message: 'Keep exploring the Pokédex.',
                  actionLabel: 'Load more',
                  onPressed: () =>
                      context.read<PokemonProvider>().loadNextPage(),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
          ],
        );
      },
    );
  }
}

class _ListHeader extends StatelessWidget {
  const _ListHeader({
    required this.controller,
    required this.loadedCount,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final int loadedCount;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        22,
        MediaQuery.paddingOf(context).top + 22,
        22,
        20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [PokedexStyle.red, PokedexStyle.darkRed],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pokédex',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Find your next favorite Pokémon',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.catching_pokemon,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search loaded Pokémon',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: onClear,
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$loadedCount Pokémon loaded',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaginationMessage extends StatelessWidget {
  const _PaginationMessage({
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(
        children: [
          Text(
            message,
            style: const TextStyle(color: PokedexStyle.muted, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          TextButton(onPressed: onPressed, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  void _openDetails(BuildContext context, PokemonSummary pokemon) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PokemonDetailScreen(pokemon: pokemon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760
            ? 4
            : constraints.maxWidth >= 520
            ? 3
            : 2;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  22,
                  MediaQuery.paddingOf(context).top + 28,
                  22,
                  25,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [PokedexStyle.red, PokedexStyle.darkRed],
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Favorites',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your personal team, all in one place',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '${favorites.count} saved Pokémon',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (favorites.favorites.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: StatusPanel(
                  icon: Icons.favorite_border_rounded,
                  title: 'No favorite Pokémon yet',
                  message:
                      'Tap the heart on a Pokémon to keep it close. Your favorites will stay here on this device.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 13,
                    mainAxisSpacing: 13,
                    mainAxisExtent: 205,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final pokemon = favorites.favorites[index];
                    return PokemonCard(
                      pokemon: pokemon,
                      isFavorite: true,
                      onTap: () => _openDetails(context, pokemon),
                      onFavoriteTap: () {
                        context.read<FavoritesProvider>().toggle(pokemon);
                      },
                    );
                  }, childCount: favorites.favorites.length),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
          ],
        );
      },
    );
  }
}
