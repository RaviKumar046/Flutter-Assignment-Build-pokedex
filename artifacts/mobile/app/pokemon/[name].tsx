import { Feather, Ionicons } from "@expo/vector-icons";
import { useQuery } from "@tanstack/react-query";
import { useLocalSearchParams, useRouter } from "expo-router";
import React from "react";
import {
  ActivityIndicator,
  Image,
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { StatBar } from "@/components/StatBar";
import { TypeChip } from "@/components/TypeChip";
import { useFavorites } from "@/context/FavoritesContext";
import { useColors } from "@/hooks/useColors";
import { fetchPokemonDetail } from "@/services/pokemonApi";

const DISPLAY_STATS = [
  "hp",
  "attack",
  "defense",
  "special-attack",
  "special-defense",
  "speed",
];

function displayName(value: string) {
  return value.replaceAll("-", " ");
}

export default function PokemonDetailScreen() {
  const colors = useColors();
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const params = useLocalSearchParams<{ name: string | string[] }>();
  const name = Array.isArray(params.name) ? params.name[0] : params.name;
  const { isFavorite, isReady, toggleFavorite } = useFavorites();
  const query = useQuery({
    queryKey: ["pokemon", "detail", name],
    queryFn: ({ signal }) => fetchPokemonDetail(name ?? "", signal),
    enabled: Boolean(name),
    staleTime: 10 * 60 * 1000,
    retry: 1,
  });

  const topPadding = Platform.OS === "web" ? 67 : insets.top;
  const detail = query.data;
  const favorite = detail ? isFavorite(detail.id) : false;

  return (
    <View style={[styles.screen, { backgroundColor: colors.background }]}>
      <View style={[styles.topBar, { paddingTop: topPadding + 8 }]}>
        <Pressable
          accessibilityRole="button"
          accessibilityLabel="Go back"
          onPress={() => router.back()}
          style={styles.backButton}
          testID="detail-back"
        >
          <Feather name="arrow-left" size={22} color={colors.foreground} />
        </Pressable>
        <Text style={[styles.topLabel, { color: colors.mutedForeground }]}>
          POKÉMON DETAILS
        </Text>
        <View style={styles.topSpacer} />
      </View>

      {query.isPending ? (
        <View style={styles.state}>
          <ActivityIndicator size="large" color={colors.primary} />
          <Text style={[styles.stateText, { color: colors.mutedForeground }]}>
            Loading Pokémon details…
          </Text>
        </View>
      ) : query.isError || !detail ? (
        <View style={styles.state}>
          <View style={[styles.stateIcon, { backgroundColor: colors.accent }]}>
            <Feather name="alert-circle" size={23} color={colors.primary} />
          </View>
          <Text style={[styles.stateTitle, { color: colors.foreground }]}>
            Couldn’t load these details
          </Text>
          <Text style={[styles.stateText, { color: colors.mutedForeground }]}>
            {query.error?.message ?? "Check your connection and try again."}
          </Text>
          <Pressable
            accessibilityRole="button"
            onPress={() => void query.refetch()}
            style={[styles.retryButton, { backgroundColor: colors.primary }]}
            testID="retry-detail"
          >
            <Text
              style={[styles.retryLabel, { color: colors.primaryForeground }]}
            >
              Try again
            </Text>
          </Pressable>
        </View>
      ) : (
        <ScrollView
          contentContainerStyle={[
            styles.content,
            { paddingBottom: Platform.OS === "web" ? 34 : insets.bottom + 24 },
          ]}
          showsVerticalScrollIndicator={false}
        >
          <View style={[styles.hero, { backgroundColor: colors.card }]}>
            <View
              style={[styles.heroOrbit, { backgroundColor: colors.accent }]}
            />
            <Text style={[styles.number, { color: colors.mutedForeground }]}>
              #{String(detail.id).padStart(3, "0")}
            </Text>
            <Image
              source={{ uri: detail.imageUrl }}
              style={styles.artwork}
              resizeMode="contain"
              accessibilityLabel={`${detail.name} official artwork`}
            />
            <Text style={[styles.name, { color: colors.foreground }]}>
              {displayName(detail.name)}
            </Text>
            <View style={styles.typeRow}>
              {detail.types.map((type) => (
                <TypeChip key={type} type={type} />
              ))}
            </View>
            <Pressable
              accessibilityRole="button"
              accessibilityLabel={
                favorite
                  ? `Remove ${detail.name} from favorites`
                  : `Add ${detail.name} to favorites`
              }
              accessibilityState={{ selected: favorite, disabled: !isReady }}
              disabled={!isReady}
              onPress={() => toggleFavorite(detail)}
              style={({ pressed }) => [
                styles.favoriteButton,
                {
                  borderColor: colors.border,
                  backgroundColor: colors.background,
                },
                pressed && styles.pressed,
              ]}
              testID={`detail-favorite-${detail.id}`}
            >
              <Ionicons
                name={favorite ? "heart" : "heart-outline"}
                size={19}
                color={favorite ? colors.destructive : colors.foreground}
              />
              <Text
                style={[styles.favoriteLabel, { color: colors.foreground }]}
              >
                {favorite ? "Saved to favorites" : "Add to favorites"}
              </Text>
            </Pressable>
          </View>

          <View style={styles.measureRow}>
            <View
              style={[
                styles.measureCard,
                { backgroundColor: colors.card, borderColor: colors.border },
              ]}
            >
              <Text
                style={[styles.measureLabel, { color: colors.mutedForeground }]}
              >
                HEIGHT
              </Text>
              <Text style={[styles.measureValue, { color: colors.foreground }]}>
                {detail.height ? `${(detail.height / 10).toFixed(1)} m` : "—"}
              </Text>
            </View>
            <View
              style={[
                styles.measureCard,
                { backgroundColor: colors.card, borderColor: colors.border },
              ]}
            >
              <Text
                style={[styles.measureLabel, { color: colors.mutedForeground }]}
              >
                WEIGHT
              </Text>
              <Text style={[styles.measureValue, { color: colors.foreground }]}>
                {detail.weight ? `${(detail.weight / 10).toFixed(1)} kg` : "—"}
              </Text>
            </View>
          </View>

          <View
            style={[
              styles.sectionCard,
              { backgroundColor: colors.card, borderColor: colors.border },
            ]}
          >
            <Text style={[styles.sectionTitle, { color: colors.foreground }]}>
              Abilities
            </Text>
            <View style={styles.abilityList}>
              {detail.abilities.length > 0 ? (
                detail.abilities.map((ability) => (
                  <View
                    key={ability}
                    style={[
                      styles.abilityPill,
                      { backgroundColor: colors.secondary },
                    ]}
                  >
                    <Text
                      style={[
                        styles.abilityText,
                        { color: colors.secondaryForeground },
                      ]}
                    >
                      {displayName(ability)}
                    </Text>
                  </View>
                ))
              ) : (
                <Text
                  style={[
                    styles.missingText,
                    { color: colors.mutedForeground },
                  ]}
                >
                  No abilities listed.
                </Text>
              )}
            </View>
          </View>

          <View
            style={[
              styles.sectionCard,
              { backgroundColor: colors.card, borderColor: colors.border },
            ]}
          >
            <View style={styles.statsHeading}>
              <Text style={[styles.sectionTitle, { color: colors.foreground }]}>
                Base stats
              </Text>
              <Text
                style={[styles.statsCaption, { color: colors.mutedForeground }]}
              >
                OUT OF 255
              </Text>
            </View>
            {DISPLAY_STATS.map((statName) => {
              const stat = detail.stats.find((item) => item.name === statName);
              return (
                <StatBar
                  key={statName}
                  name={statName}
                  value={stat?.value ?? 0}
                />
              );
            })}
          </View>
        </ScrollView>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  screen: {
    flex: 1,
  },
  topBar: {
    paddingHorizontal: 20,
    minHeight: 52,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
  },
  backButton: {
    width: 42,
    height: 42,
    justifyContent: "center",
  },
  topLabel: {
    fontSize: 10,
    letterSpacing: 1.5,
    fontFamily: "Inter_700Bold",
  },
  topSpacer: {
    width: 42,
  },
  content: {
    paddingHorizontal: 20,
    paddingTop: 10,
    gap: 12,
  },
  hero: {
    borderRadius: 24,
    alignItems: "center",
    overflow: "hidden",
    paddingHorizontal: 20,
    paddingTop: 15,
    paddingBottom: 18,
    position: "relative",
  },
  heroOrbit: {
    width: 210,
    height: 210,
    borderRadius: 105,
    position: "absolute",
    top: 46,
  },
  number: {
    alignSelf: "flex-start",
    fontSize: 12,
    letterSpacing: 0.8,
    fontFamily: "Inter_600SemiBold",
  },
  artwork: {
    width: 206,
    height: 206,
    marginTop: -3,
  },
  name: {
    fontSize: 30,
    lineHeight: 36,
    textTransform: "capitalize",
    fontFamily: "Inter_700Bold",
    letterSpacing: -0.6,
  },
  typeRow: {
    flexDirection: "row",
    justifyContent: "center",
    gap: 8,
    marginTop: 11,
  },
  favoriteButton: {
    minHeight: 42,
    borderRadius: 15,
    borderWidth: 1,
    paddingHorizontal: 16,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: 8,
    marginTop: 15,
  },
  favoriteLabel: {
    fontSize: 12,
    fontFamily: "Inter_600SemiBold",
  },
  pressed: {
    opacity: 0.68,
  },
  measureRow: {
    flexDirection: "row",
    gap: 12,
  },
  measureCard: {
    flex: 1,
    borderWidth: 1,
    borderRadius: 19,
    paddingVertical: 14,
    paddingHorizontal: 15,
  },
  measureLabel: {
    fontSize: 9,
    letterSpacing: 1.3,
    fontFamily: "Inter_700Bold",
  },
  measureValue: {
    marginTop: 5,
    fontSize: 18,
    fontFamily: "Inter_700Bold",
  },
  sectionCard: {
    borderWidth: 1,
    borderRadius: 19,
    padding: 16,
  },
  sectionTitle: {
    fontSize: 16,
    fontFamily: "Inter_700Bold",
  },
  abilityList: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 8,
    marginTop: 12,
  },
  abilityPill: {
    borderRadius: 13,
    paddingHorizontal: 11,
    paddingVertical: 8,
  },
  abilityText: {
    fontSize: 12,
    textTransform: "capitalize",
    fontFamily: "Inter_500Medium",
  },
  missingText: {
    fontSize: 12,
    fontFamily: "Inter_400Regular",
    marginTop: 8,
  },
  statsHeading: {
    flexDirection: "row",
    alignItems: "baseline",
    justifyContent: "space-between",
    marginBottom: 10,
  },
  statsCaption: {
    fontSize: 9,
    letterSpacing: 1,
    fontFamily: "Inter_600SemiBold",
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
    marginTop: 7,
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
});
