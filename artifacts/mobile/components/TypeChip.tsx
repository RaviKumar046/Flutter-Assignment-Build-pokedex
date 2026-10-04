import React from "react";
import { StyleSheet, Text, View } from "react-native";
import { useColors } from "@/hooks/useColors";

export function TypeChip({ type }: { type: string }) {
  const colors = useColors();
  const key = type as keyof typeof colors.pokemonTypes;
  const color = colors.pokemonTypes[key] ?? colors.primary;
  return (
    <View style={[styles.chip, { backgroundColor: color }]}>
      <Text style={[styles.text, { color: colors.typeForeground }]}>
        {type}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  chip: {
    borderRadius: 30,
    paddingHorizontal: 14,
    paddingVertical: 7,
    minWidth: 74,
    alignItems: "center",
  },
  text: {
    fontSize: 12,
    lineHeight: 16,
    textTransform: "capitalize",
    fontFamily: "Inter_600SemiBold",
  },
});
