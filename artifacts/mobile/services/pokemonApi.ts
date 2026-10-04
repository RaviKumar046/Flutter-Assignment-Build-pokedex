export interface PokemonSummary {
  id: number;
  name: string;
  imageUrl: string;
}

export interface PokemonPage {
  count: number;
  nextOffset: number | null;
  results: PokemonSummary[];
}

export interface PokemonStat {
  name: string;
  value: number;
}

export interface PokemonDetail {
  id: number;
  name: string;
  imageUrl: string;
  types: string[];
  height: number;
  weight: number;
  abilities: string[];
  stats: PokemonStat[];
}

const API_BASE = "https://pokeapi.co/api/v2";
const OFFICIAL_ARTWORK =
  "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork";

type JsonRecord = Record<string, unknown>;

function isRecord(value: unknown): value is JsonRecord {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function getString(value: unknown): string | null {
  return typeof value === "string" && value.length > 0 ? value : null;
}

function getNumber(value: unknown): number | null {
  return typeof value === "number" && Number.isFinite(value) ? value : null;
}

function getIdFromUrl(url: string): number | null {
  const match = url.match(/\/pokemon\/(\d+)\/?$/);
  return match ? Number(match[1]) : null;
}

function getOffsetFromUrl(url: string | null): number | null {
  if (!url) return null;
  try {
    const value = new URL(url).searchParams.get("offset");
    const offset = value === null ? null : Number(value);
    return offset !== null && Number.isInteger(offset) && offset >= 0
      ? offset
      : null;
  } catch {
    return null;
  }
}

function parseSummary(value: unknown): PokemonSummary | null {
  if (!isRecord(value)) return null;
  const name = getString(value.name);
  const url = getString(value.url);
  if (!name || !url) return null;

  const id = getIdFromUrl(url);
  if (!id) return null;
  return { id, name, imageUrl: `${OFFICIAL_ARTWORK}/${id}.png` };
}

async function readResponse(response: Response): Promise<unknown> {
  if (!response.ok) {
    throw new Error(
      `PokéAPI returned ${response.status}. Please try again in a moment.`,
    );
  }
  return response.json() as Promise<unknown>;
}

export async function fetchPokemonPage(
  offset: number,
  signal?: AbortSignal,
): Promise<PokemonPage> {
  const response = await fetch(
    `${API_BASE}/pokemon?limit=20&offset=${offset}`,
    { signal },
  );
  const payload = await readResponse(response);

  if (!isRecord(payload) || !Array.isArray(payload.results)) {
    throw new Error("PokéAPI returned an unexpected list response.");
  }

  const results = payload.results
    .map(parseSummary)
    .filter((pokemon): pokemon is PokemonSummary => pokemon !== null);
  if (results.length === 0 && payload.results.length > 0) {
    throw new Error("PokéAPI returned Pokémon entries that could not be read.");
  }

  return {
    count: getNumber(payload.count) ?? 0,
    nextOffset: getOffsetFromUrl(getString(payload.next)),
    results,
  };
}

function readNestedImage(value: unknown): string | null {
  if (!isRecord(value)) return null;
  const sprites = isRecord(value.sprites) ? value.sprites : null;
  const other = sprites && isRecord(sprites.other) ? sprites.other : null;
  const artwork =
    other && isRecord(other["official-artwork"])
      ? other["official-artwork"]
      : null;
  return (
    getString(artwork?.front_default) ??
    getString(sprites?.front_default) ??
    null
  );
}

export async function fetchPokemonDetail(
  nameOrId: string,
  signal?: AbortSignal,
): Promise<PokemonDetail> {
  const response = await fetch(
    `${API_BASE}/pokemon/${encodeURIComponent(nameOrId.toLowerCase())}`,
    { signal },
  );
  const payload = await readResponse(response);

  if (!isRecord(payload)) {
    throw new Error("PokéAPI returned an unexpected Pokémon response.");
  }

  const id = getNumber(payload.id);
  const name = getString(payload.name);
  if (!id || !name) {
    throw new Error("PokéAPI returned incomplete Pokémon details.");
  }

  const types = Array.isArray(payload.types)
    ? payload.types
        .map((entry) => {
          if (!isRecord(entry) || !isRecord(entry.type)) return null;
          return getString(entry.type.name);
        })
        .filter((type): type is string => type !== null)
    : [];

  const abilities = Array.isArray(payload.abilities)
    ? payload.abilities
        .map((entry) => {
          if (!isRecord(entry) || !isRecord(entry.ability)) return null;
          return getString(entry.ability.name);
        })
        .filter((ability): ability is string => ability !== null)
    : [];

  const stats: PokemonStat[] = Array.isArray(payload.stats)
    ? payload.stats
        .map((entry) => {
          if (!isRecord(entry) || !isRecord(entry.stat)) return null;
          const statName = getString(entry.stat.name);
          const value = getNumber(entry.base_stat);
          return statName && value !== null ? { name: statName, value } : null;
        })
        .filter((stat): stat is PokemonStat => stat !== null)
    : [];

  return {
    id,
    name,
    imageUrl: readNestedImage(payload) ?? `${OFFICIAL_ARTWORK}/${id}.png`,
    types,
    height: getNumber(payload.height) ?? 0,
    weight: getNumber(payload.weight) ?? 0,
    abilities,
    stats,
  };
}

export function summaryFromFavorite(favorite: {
  id: number;
  name: string;
}): PokemonSummary {
  return {
    ...favorite,
    imageUrl: `${OFFICIAL_ARTWORK}/${favorite.id}.png`,
  };
}
