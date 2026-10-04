import { Feather, Ionicons } from "@expo/vector-icons";
import React, { useState } from "react";
import { Image, Pressable, StyleSheet, Text, View } from "react-native";
import { useFavorites } from "@/context/FavoritesContext";
import type { PokemonSummary } from "@/services/pokemonApi";
import { useColors } from "@/hooks/useColors";

interface PokemonCardProps {
  pokemon: PokemonSummary;
  onPress: () => void;
}

function formatId(id: number) {
  return `#${String(id).padStart(3, "0")}`;
}

export function PokemonCard({ pokemon, onPress }: PokemonCardProps) {
  const colors = useColors();
  const { isFavorite, isReady, toggleFavorite } = useFavorites();
  const [imageFailed, setImageFailed] = useState(false);
  const favorite = isFavorite(pokemon.id);

  return (
    <View
      style={[
        styles.card,
        { backgroundColor: colors.card, borderColor: colors.border },
      ]}
    >
      <View
        pointerEvents="none"
        style={[styles.orbit, { backgroundColor: colors.accent }]}
      />
      <Pressable
        accessibilityRole="button"
        accessibilityLabel={`Open ${pokemon.name}`}
        onPress={onPress}
        style={({ pressed }) => [styles.content, pressed && styles.pressed]}
        testID={`pokemon-card-${pokemon.id}`}
      >
        <Text style={[styles.number, { color: colors.mutedForeground }]}>
          {formatId(pokemon.id)}
        </Text>
        <View style={styles.imageWrap}>
          {imageFailed ? (
            <Feather name="circle" size={54} color={colors.mutedForeground} />
          ) : (
            <Image
              source={{ uri: pokemon.imageUrl }}
              style={styles.image}
              resizeMode="contain"
              onError={() => setImageFailed(true)}
              accessibilityLabel={`${pokemon.name} artwork`}
            />
          )}
        </View>
        <Text
          numberOfLines={1}
          style={[styles.name, { color: colors.foreground }]}
        >
          {pokemon.name}
        </Text>
      </Pressable>
      <Pressable
        accessibilityRole="button"
        accessibilityLabel={
          favorite
            ? `Remove ${pokemon.name} from favorites`
            : `Add ${pokemon.name} to favorites`
        }
        accessibilityState={{ selected: favorite, disabled: !isReady }}
        disabled={!isReady}
        onPress={() => toggleFavorite(pokemon)}
        style={({ pressed }) => [
          styles.favoriteButton,
          pressed && styles.pressed,
        ]}
        testID={`favorite-${pokemon.id}`}
      >
        <Ionicons
          name={favorite ? "heart" : "heart-outline"}
          size={21}
          color={favorite ? colors.destructive : colors.mutedForeground}
        />
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    width: "48%",
    minHeight: 190,
    marginBottom: 12,
    borderWidth: 1,
    borderRadius: 22,
    overflow: "hidden",
    position: "relative",
  },
  orbit: {
    position: "absolute",
    width: 116,
    height: 116,
    borderRadius: 58,
    top: 35,
    left: "50%",
    marginLeft: -58,
    opacity: 0.68,
  },
  content: {
    flex: 1,
    alignItems: "center",
    paddingHorizontal: 12,
    paddingTop: 13,
    paddingBottom: 14,
  },
  number: {
    alignSelf: "flex-start",
    fontSize: 11,
    fontFamily: "Inter_600SemiBold",
    letterSpacing: 0.7,
  },
  imageWrap: {
    height: 116,
    width: "100%",
    alignItems: "center",
    justifyContent: "center",
  },
  image: {
    width: 116,
    height: 116,
  },
  name: {
    marginTop: 2,
    fontSize: 14,
    lineHeight: 20,
    textTransform: "capitalize",
    fontFamily: "Inter_600SemiBold",
  },
  favoriteButton: {
    position: "absolute",
    right: 8,
    top: 8,
    width: 36,
    height: 36,
    alignItems: "center",
    justifyContent: "center",
  },
  pressed: {
    opacity: 0.68,
  },
});
