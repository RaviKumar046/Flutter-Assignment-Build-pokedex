import { Feather, Ionicons } from "@expo/vector-icons";
import { useInfiniteQuery } from "@tanstack/react-query";
import { useRouter } from "expo-router";
import React, { useMemo, useState } from "react";
import {
  ActivityIndicator,
  FlatList,
  Platform,
  Pressable,
  RefreshControl,
  StyleSheet,
  Text,
  TextInput,
  View,
} from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { PokemonCard } from "@/components/PokemonCard";
import { useFavorites } from "@/context/FavoritesContext";
import { useColors } from "@/hooks/useColors";
import { fetchPokemonPage, type PokemonSummary } from "@/services/pokemonApi";

function formatCount(count: number) {
  return new Intl.NumberFormat().format(count);
}

export default function BrowseScreen() {
  const colors = useColors();
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const { persistenceError } = useFavorites();
  const [search, setSearch] = useState("");
  const query = useInfiniteQuery({
    queryKey: ["pokemon", "list"],
    initialPageParam: 0,
    queryFn: ({ pageParam, signal }) => fetchPokemonPage(pageParam, signal),
    getNextPageParam: (lastPage) => lastPage.nextOffset ?? undefined,
    staleTime: 5 * 60 * 1000,
    retry: 1,
  });

  const loadedPokemon = useMemo(() => {
    const unique = new Map<number, PokemonSummary>();
    for (const page of query.data?.pages ?? []) {
      for (const pokemon of page.results) unique.set(pokemon.id, pokemon);
    }
    return Array.from(unique.values());
  }, [query.data]);

  const normalizedSearch = search.trim().toLowerCase();
  const visiblePokemon = useMemo(
    () =>
      normalizedSearch
        ? loadedPokemon.filter((pokemon) =>
            pokemon.name.includes(normalizedSearch),
          )
        : loadedPokemon,
    [loadedPokemon, normalizedSearch],
  );
  const totalCount = query.data?.pages[0]?.count ?? 0;
  const topPadding = Platform.OS === "web" ? 67 : insets.top;

  const openPokemon = (pokemon: PokemonSummary) => {
    router.push({
      pathname: "/pokemon/[name]",
      params: { name: pokemon.name },
    });
  };

  return (
    <View
      style={[
        styles.screen,
        { backgroundColor: colors.background, paddingTop: topPadding + 12 },
      ]}
    >
      <View style={styles.header}>
        <View>
          <Text style={[styles.eyebrow, { color: colors.primary }]}>
            YOUR FIELD GUIDE
          </Text>
          <Text style={[styles.title, { color: colors.foreground }]}>
            Pokédex
          </Text>
          <Text style={[styles.subtitle, { color: colors.mutedForeground }]}>
            Discover Pokémon, one at a time.
          </Text>
        </View>
        <View style={[styles.countBadge, { backgroundColor: colors.accent }]}>
          <Text style={[styles.countValue, { color: colors.accentForeground }]}>
            {formatCount(totalCount || loadedPokemon.length)}
          </Text>
          <Text style={[styles.countLabel, { color: colors.accentForeground }]}>
            to find
          </Text>
        </View>
      </View>

      <View
        style={[
          styles.searchBox,
          { backgroundColor: colors.card, borderColor: colors.border },
        ]}
      >
        <Feather name="search" size={18} color={colors.mutedForeground} />
        <TextInput
          accessibilityLabel="Search loaded Pokémon"
          autoCapitalize="none"
          autoCorrect={false}
          onChangeText={setSearch}
          placeholder="Search Pokémon"
          placeholderTextColor={colors.mutedForeground}
          returnKeyType="search"
          style={[styles.searchInput, { color: colors.foreground }]}
          testID="pokemon-search"
          value={search}
        />
        {search.length > 0 ? (
          <Pressable
            accessibilityRole="button"
            accessibilityLabel="Clear search"
            onPress={() => setSearch("")}
            hitSlop={10}
            testID="clear-search"
          >
            <Ionicons
              name="close-circle"
              size={19}
              color={colors.mutedForeground}
            />
          </Pressable>
        ) : (
          <Feather name="sliders" size={17} color={colors.mutedForeground} />
        )}
      </View>

      {persistenceError ? (
        <Text style={[styles.storageNotice, { color: colors.destructive }]}>
          {persistenceError}
        </Text>
      ) : null}
      <View style={styles.sectionHeading}>
        <Text style={[styles.sectionTitle, { color: colors.foreground }]}>
          {normalizedSearch ? "Search results" : "Pokémon"}
        </Text>
        <Text style={[styles.sectionCount, { color: colors.mutedForeground }]}>
          {normalizedSearch
            ? `${visiblePokemon.length} loaded`
            : `${loadedPokemon.length} loaded`}
        </Text>
      </View>

      {query.isPending ? (
        <View style={styles.state}>
          <ActivityIndicator size="large" color={colors.primary} />
          <Text style={[styles.stateText, { color: colors.mutedForeground }]}>
            Loading Pokémon…
          </Text>
        </View>
      ) : query.isError && !query.data ? (
        <View style={styles.state}>
          <View style={[styles.stateIcon, { backgroundColor: colors.accent }]}>
            <Feather name="wifi-off" size={23} color={colors.primary} />
          </View>
          <Text style={[styles.stateTitle, { color: colors.foreground }]}>
            Couldn’t load Pokémon
          </Text>
          <Text style={[styles.stateText, { color: colors.mutedForeground }]}>
            {query.error.message || "Check your connection and try again."}
          </Text>
          <Pressable
            accessibilityRole="button"
            onPress={() => void query.refetch()}
            style={[styles.retryButton, { backgroundColor: colors.primary }]}
            testID="retry-pokemon"
          >
            <Text
              style={[styles.retryLabel, { color: colors.primaryForeground }]}
            >
              Try again
            </Text>
          </Pressable>
        </View>
      ) : (
        <FlatList
          data={visiblePokemon}
          keyExtractor={(pokemon) => String(pokemon.id)}
          numColumns={2}
          columnWrapperStyle={styles.columns}
          contentContainerStyle={styles.listContent}
          showsVerticalScrollIndicator={false}
          scrollEnabled={visiblePokemon.length > 0}
          refreshControl={
            <RefreshControl
              refreshing={query.isRefetching && !query.isFetchingNextPage}
              onRefresh={() => void query.refetch()}
              tintColor={colors.primary}
              colors={[colors.primary]}
            />
          }
          renderItem={({ item }) => (
            <PokemonCard pokemon={item} onPress={() => openPokemon(item)} />
          )}
          onEndReached={() => {
            if (
              !normalizedSearch &&
              query.hasNextPage &&
              !query.isFetchingNextPage &&
              !query.isFetchNextPageError
            ) {
              void query.fetchNextPage();
            }
          }}
          onEndReachedThreshold={0.45}
          ListEmptyComponent={
            <View style={styles.empty}>
              <View
                style={[styles.stateIcon, { backgroundColor: colors.accent }]}
              >
                <Feather name="search" size={22} color={colors.primary} />
              </View>
              <Text style={[styles.stateTitle, { color: colors.foreground }]}>
                No matches found
              </Text>
              <Text
                style={[styles.stateText, { color: colors.mutedForeground }]}
              >
                Try another name or load more Pokémon.
              </Text>
            </View>
          }
          ListFooterComponent={
            query.isFetchingNextPage ? (
              <View style={styles.footer}>
                <ActivityIndicator color={colors.primary} />
                <Text
                  style={[styles.footerText, { color: colors.mutedForeground }]}
                >
                  Finding more Pokémon…
                </Text>
              </View>
            ) : query.isFetchNextPageError ? (
              <View style={styles.footer}>
                <Text
                  style={[styles.footerText, { color: colors.destructive }]}
                >
                  Couldn’t load the next page.
                </Text>
                <Pressable
                  accessibilityRole="button"
                  onPress={() => void query.fetchNextPage()}
                  style={styles.footerRetry}
                  testID="retry-next-page"
                >
                  <Text
                    style={[styles.footerRetryText, { color: colors.primary }]}
                  >
                    Retry
                  </Text>
                </Pressable>
              </View>
            ) : (
              <View style={{ height: 18 }} />
            )
          }
          testID="pokemon-list"
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  screen: {
    flex: 1,
    paddingHorizontal: 20,
  },
  header: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    marginBottom: 18,
  },
  eyebrow: {
    fontSize: 10,
    letterSpacing: 1.7,
    fontFamily: "Inter_700Bold",
    marginBottom: 5,
  },
  title: {
    fontSize: 30,
    lineHeight: 36,
    letterSpacing: -0.9,
    fontFamily: "Inter_700Bold",
  },
  subtitle: {
    marginTop: 3,
    fontSize: 13,
    fontFamily: "Inter_400Regular",
  },
  countBadge: {
    width: 61,
    height: 61,
    borderRadius: 31,
    alignItems: "center",
    justifyContent: "center",
  },
  countValue: {
    fontSize: 14,
    fontFamily: "Inter_700Bold",
  },
  countLabel: {
    fontSize: 8,
    fontFamily: "Inter_500Medium",
    marginTop: 1,
  },
  searchBox: {
    height: 48,
    borderRadius: 16,
    borderWidth: 1,
    flexDirection: "row",
    alignItems: "center",
    gap: 10,
    paddingHorizontal: 14,
    marginBottom: 21,
  },
  searchInput: {
    flex: 1,
    height: "100%",
    fontSize: 14,
    fontFamily: "Inter_400Regular",
  },
  storageNotice: {
    fontSize: 12,
    fontFamily: "Inter_500Medium",
    marginTop: -12,
    marginBottom: 10,
  },
  sectionHeading: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "baseline",
    marginBottom: 12,
  },
  sectionTitle: {
    fontSize: 17,
    fontFamily: "Inter_700Bold",
  },
  sectionCount: {
    fontSize: 11,
    fontFamily: "Inter_500Medium",
  },
  listContent: {
    flexGrow: 1,
    paddingBottom: 16,
  },
  columns: {
    justifyContent: "space-between",
  },
  state: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    paddingHorizontal: 28,
    paddingBottom: 40,
  },
  stateIcon: {
    width: 54,
    height: 54,
    borderRadius: 27,
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 13,
  },
  stateTitle: {
    fontSize: 17,
    fontFamily: "Inter_700Bold",
    textAlign: "center",
  },
  stateText: {
    fontSize: 13,
    lineHeight: 19,
    textAlign: "center",
    marginTop: 6,
    fontFamily: "Inter_400Regular",
  },
  retryButton: {
    minHeight: 42,
    minWidth: 120,
    alignItems: "center",
    justifyContent: "center",
    paddingHorizontal: 18,
    borderRadius: 14,
    marginTop: 18,
  },
  retryLabel: {
    fontSize: 13,
    fontFamily: "Inter_600SemiBold",
  },
  empty: {
    flexGrow: 1,
    alignItems: "center",
    justifyContent: "center",
    paddingHorizontal: 18,
    minHeight: 260,
  },
  footer: {
    alignItems: "center",
    justifyContent: "center",
    minHeight: 66,
    gap: 8,
    flexDirection: "row",
  },
  footerText: {
    fontSize: 12,
    fontFamily: "Inter_500Medium",
  },
  footerRetry: {
    minHeight: 40,
    minWidth: 50,
    alignItems: "center",
    justifyContent: "center",
  },
  footerRetryText: {
    fontSize: 13,
    fontFamily: "Inter_700Bold",
  },
});
