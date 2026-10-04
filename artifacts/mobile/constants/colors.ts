/**
 * Semantic design tokens for the mobile app.
 *
 * These tokens mirror the naming conventions used in web artifacts (index.css)
 * so that multi-artifact projects share a cohesive visual identity.
 *
 * Replace the placeholder values below with values that match the project's
 * brand. If a sibling web artifact exists, read its index.css and convert the
 * HSL values to hex so both artifacts use the same palette.
 *
 * To add dark mode, add a `dark` key with the same token names.
 * The useColors() hook will automatically pick it up.
 */

const colors = {
  light: {
    text: "#17202b",
    tint: "#e34843",
    background: "#f7f5f1",
    foreground: "#17202b",
    card: "#ffffff",
    cardForeground: "#17202b",
    primary: "#df4642",
    primaryForeground: "#ffffff",
    secondary: "#edf0f3",
    secondaryForeground: "#263243",
    muted: "#edf0f3",
    mutedForeground: "#77818e",
    accent: "#f4e7e2",
    accentForeground: "#8e3636",
    destructive: "#e34843",
    destructiveForeground: "#ffffff",
    border: "#e8e7e3",
    input: "#e8e7e3",
    typeForeground: "#ffffff",
    pokemonTypes: {
      normal: "#8a8f9a",
      fire: "#e76b3c",
      water: "#4f8bdc",
      electric: "#daa92e",
      grass: "#62a96c",
      ice: "#62b4b0",
      fighting: "#bd514b",
      poison: "#9860ad",
      ground: "#b18a4d",
      flying: "#7a82ca",
      psychic: "#d65d91",
      bug: "#84963d",
      rock: "#96804c",
      ghost: "#6b62a2",
      dragon: "#6655be",
      dark: "#605c62",
      steel: "#718b98",
      fairy: "#d678a1",
    },
  },
  dark: {
    text: "#f3f4f5",
    tint: "#f26a61",
    background: "#111821",
    foreground: "#f3f4f5",
    card: "#1a2531",
    cardForeground: "#f3f4f5",
    primary: "#f26a61",
    primaryForeground: "#111821",
    secondary: "#263442",
    secondaryForeground: "#e9edf0",
    muted: "#293642",
    mutedForeground: "#a4afb8",
    accent: "#3a2b32",
    accentForeground: "#ffd8d2",
    destructive: "#ff7a70",
    destructiveForeground: "#111821",
    border: "#2a3743",
    input: "#35414d",
    typeForeground: "#ffffff",
    pokemonTypes: {
      normal: "#8a8f9a",
      fire: "#e76b3c",
      water: "#4f8bdc",
      electric: "#daa92e",
      grass: "#62a96c",
      ice: "#62b4b0",
      fighting: "#bd514b",
      poison: "#9860ad",
      ground: "#b18a4d",
      flying: "#7a82ca",
      psychic: "#d65d91",
      bug: "#84963d",
      rock: "#96804c",
      ghost: "#6b62a2",
      dragon: "#6655be",
      dark: "#605c62",
      steel: "#718b98",
      fairy: "#d678a1",
    },
  },
  radius: 20,
};

export default colors;
