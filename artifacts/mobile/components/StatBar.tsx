import React from "react";
import { StyleSheet, Text, View } from "react-native";
import { useColors } from "@/hooks/useColors";

const LABELS: Record<string, string> = {
  hp: "HP",
  attack: "Attack",
  defense: "Defense",
  "special-attack": "Sp. Attack",
  "special-defense": "Sp. Defense",
  speed: "Speed",
};

export function StatBar({ name, value }: { name: string; value: number }) {
  const colors = useColors();
  return (
    <View style={styles.row}>
      <Text style={[styles.label, { color: colors.mutedForeground }]}>
        {LABELS[name] ?? name}
      </Text>
      <Text style={[styles.value, { color: colors.foreground }]}>{value}</Text>
      <View style={[styles.track, { backgroundColor: colors.muted }]}>
        <View
          style={[
            styles.fill,
            {
              width: `${Math.min(Math.max(value / 255, 0), 1) * 100}%`,
              backgroundColor: colors.primary,
            },
          ]}
        />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  row: {
    minHeight: 34,
    flexDirection: "row",
    alignItems: "center",
    gap: 10,
  },
  label: {
    width: 77,
    fontSize: 12,
    fontFamily: "Inter_500Medium",
  },
  value: {
    width: 26,
    fontSize: 12,
    textAlign: "right",
    fontFamily: "Inter_600SemiBold",
  },
  track: {
    height: 7,
    flex: 1,
    overflow: "hidden",
    borderRadius: 4,
  },
  fill: {
    height: "100%",
    borderRadius: 4,
  },
});
