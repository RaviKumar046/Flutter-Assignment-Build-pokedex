import AsyncStorage from "@react-native-async-storage/async-storage";
import React, {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
  type ReactNode,
} from "react";

const STORAGE_KEY = "@pokedex/favorites-v1";

export interface FavoritePokemon {
  id: number;
  name: string;
}

interface FavoritesContextValue {
  favorites: FavoritePokemon[];
  isReady: boolean;
  persistenceError: string | null;
  isFavorite: (id: number) => boolean;
  toggleFavorite: (pokemon: FavoritePokemon) => void;
}

const FavoritesContext = createContext<FavoritesContextValue | null>(null);

function parseFavorites(raw: string | null): FavoritePokemon[] {
  if (!raw) return [];
  try {
    const value: unknown = JSON.parse(raw);
    if (!Array.isArray(value)) return [];
    const seen = new Set<number>();
    return value.filter((entry): entry is FavoritePokemon => {
      if (
        typeof entry !== "object" ||
        entry === null ||
        !("id" in entry) ||
        !("name" in entry) ||
        typeof entry.id !== "number" ||
        !Number.isInteger(entry.id) ||
        entry.id <= 0 ||
        typeof entry.name !== "string" ||
        entry.name.length === 0 ||
        seen.has(entry.id)
      ) {
        return false;
      }
      seen.add(entry.id);
      return true;
    });
  } catch {
    return [];
  }
}

export function FavoritesProvider({ children }: { children: ReactNode }) {
  const [favorites, setFavorites] = useState<FavoritePokemon[]>([]);
  const [isReady, setIsReady] = useState(false);
  const [persistenceError, setPersistenceError] = useState<string | null>(null);
  const favoritesRef = useRef<FavoritePokemon[]>([]);
  const persistQueue = useRef<Promise<void>>(Promise.resolve());

  useEffect(() => {
    let active = true;
    AsyncStorage.getItem(STORAGE_KEY)
      .then((raw) => {
        if (!active) return;
        const saved = parseFavorites(raw);
        favoritesRef.current = saved;
        setFavorites(saved);
      })
      .catch(() => {
        if (active) {
          setPersistenceError("Saved favorites could not be loaded.");
        }
      })
      .finally(() => {
        if (active) setIsReady(true);
      });
    return () => {
      active = false;
    };
  }, []);

  const isFavorite = useCallback(
    (id: number) => favorites.some((favorite) => favorite.id === id),
    [favorites],
  );

  const toggleFavorite = useCallback(
    (pokemon: FavoritePokemon) => {
      if (!isReady) return;

      const exists = favoritesRef.current.some(
        (favorite) => favorite.id === pokemon.id,
      );
      const next = exists
        ? favoritesRef.current.filter((favorite) => favorite.id !== pokemon.id)
        : [...favoritesRef.current, { id: pokemon.id, name: pokemon.name }];

      // Update memory first so every screen responds immediately.
      favoritesRef.current = next;
      setFavorites(next);
      setPersistenceError(null);

      const write = persistQueue.current.then(() =>
        AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(next)),
      );
      persistQueue.current = write.catch(() => undefined);
      void write.catch(() => {
        setPersistenceError("A favorite changed, but could not be saved.");
      });
    },
    [isReady],
  );

  const value = useMemo(
    () => ({
      favorites,
      isReady,
      persistenceError,
      isFavorite,
      toggleFavorite,
    }),
    [favorites, isReady, persistenceError, isFavorite, toggleFavorite],
  );

  return (
    <FavoritesContext.Provider value={value}>
      {children}
    </FavoritesContext.Provider>
  );
}

export function useFavorites() {
  const context = useContext(FavoritesContext);
  if (!context) {
    throw new Error("useFavorites must be used within FavoritesProvider.");
  }
  return context;
}
