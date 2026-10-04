import { Feather } from "@expo/vector-icons";
import { useRouter } from "expo-router";
import React from "react";
import {
  ActivityIndicator,
  FlatList,
  Platform,
  StyleSheet,
  Text,
  View,
} from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { PokemonCard } from "@/components/PokemonCard";
import { useFavorites } from "@/context/FavoritesContext";
import { useColors } from "@/hooks/useColors";
import { summaryFromFavorite } from "@/services/pokemonApi";

export default function FavoritesScreen() {
  const colors = useColors();
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const { favorites, isReady, persistenceError } = useFavorites();
  const pokemon = favorites.map(summaryFromFavorite);
  const topPadding = Platform.OS === "web" ? 67 : insets.top;

  return (
    <View
      style={[
        styles.screen,
        { backgroundColor: colors.background, paddingTop: topPadding + 12 },
      ]}
    >
      <View style={styles.header}>
        <Text style={[styles.eyebrow, { color: colors.primary }]}>
          YOUR COLLECTION
        </Text>
        <Text style={[styles.title, { color: colors.foreground }]}>
          Favorites
        </Text>
        <Text style={[styles.subtitle, { color: colors.mutedForeground }]}>
          The ones you want to keep close.
        </Text>
      </View>

      {persistenceError ? (
        <Text style={[styles.storageNotice, { color: colors.destructive }]}>
          {persistenceError}
        </Text>
      ) : null}

      {!isReady ? (
        <View style={styles.center}>
          <ActivityIndicator color={colors.primary} size="large" />
          <Text style={[styles.stateText, { color: colors.mutedForeground }]}>
            Restoring your favorites…
          </Text>
        </View>
      ) : (
        <FlatList
          data={pokemon}
          keyExtractor={(item) => String(item.id)}
          numColumns={2}
          columnWrapperStyle={styles.columns}
          contentContainerStyle={[
            styles.listContent,
            pokemon.length === 0 && styles.emptyList,
          ]}
          scrollEnabled={pokemon.length > 0}
          showsVerticalScrollIndicator={false}
          renderItem={({ item }) => (
            <PokemonCard
              pokemon={item}
              onPress={() =>
                router.push({
                  pathname: "/pokemon/[name]",
                  params: { name: item.name },
                })
              }
            />
          )}
          ListEmptyComponent={
            <View style={styles.empty}>
              <View
                style={[styles.heartCircle, { backgroundColor: colors.accent }]}
              >
                <Feather name="heart" size={24} color={colors.primary} />
              </View>
              <Text style={[styles.emptyTitle, { color: colors.foreground }]}>
                No favorite Pokémon yet
              </Text>
              <Text
                style={[styles.stateText, { color: colors.mutedForeground }]}
              >
                Tap the heart on any Pokémon to save it here.
              </Text>
            </View>
          }
          testID="favorites-list"
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
    marginBottom: 24,
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
    marginTop: 4,
    fontSize: 13,
    fontFamily: "Inter_400Regular",
  },
  storageNotice: {
    fontSize: 12,
    fontFamily: "Inter_500Medium",
    marginTop: -13,
    marginBottom: 14,
  },
  listContent: {
    flexGrow: 1,
    paddingBottom: 18,
  },
  emptyList: {
    justifyContent: "center",
  },
  columns: {
    justifyContent: "space-between",
  },
  center: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    paddingBottom: 44,
  },
  empty: {
    alignItems: "center",
    justifyContent: "center",
    paddingHorizontal: 22,
    paddingBottom: 38,
  },
  heartCircle: {
    width: 62,
    height: 62,
    borderRadius: 31,
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 16,
  },
  emptyTitle: {
    fontSize: 17,
    fontFamily: "Inter_700Bold",
    textAlign: "center",
  },
  stateText: {
    fontSize: 13,
    lineHeight: 19,
    fontFamily: "Inter_400Regular",
    textAlign: "center",
    marginTop: 7,
  },
});
