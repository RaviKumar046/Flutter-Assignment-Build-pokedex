# Pokédex

A portrait-first mobile Pokédex for browsing the PokéAPI, exploring Pokémon details, and keeping a personal favorites list.

> **Platform note:** The assignment describes a Flutter/Dart application, while this project was requested as an Expo mobile artifact and no Flutter repository was provided. This deliverable implements the assignment in Expo, React Native, and TypeScript; it is not a Flutter/Dart project.

## Features

- Browse Pokémon in API pages of 20 with infinite scrolling.
- Search by name among Pokémon already loaded on the device.
- Open a detail page with official artwork, types, height, weight, abilities, and six base stats.
- Add or remove favorites from browse cards or the detail page.
- See the same favorite state on every screen; favorites are saved locally and restored at launch.
- Retry failed list, next-page, and detail requests; the existing list remains visible if loading a later page fails.
- Pull down to refresh the list.

## Screens

- **Browse** — paginated Pokémon list, loaded-item search, loading/error/empty states.
- **Favorites** — locally saved Pokémon, with an empty state and live removal.
- **Pokémon details** — API-backed profile and shared favorite control.

## Run

Install the workspace dependencies from the repository root with `pnpm install`, then start the Expo mobile workflow. The app can also be opened in Expo Go from the Replit mobile preview.

## API

The app calls the public [PokéAPI](https://pokeapi.co/api/v2/) directly:

- `GET /pokemon?limit=20&offset={offset}` for list pages.
- `GET /pokemon/{name_or_id}` for details.

No API key or authentication is needed. List requests use the API's `next` URL to determine the next offset. Names and URLs are validated before a list entry is displayed; detail fields are parsed defensively.

## State and persistence

Favorite state lives in one React Context provider at the app root. The provider exposes the current favorite IDs/names and a single toggle action, so browse, detail, and favorites screens always read and update the same in-memory source of truth.

**Why Context:** It is built into React, is sufficient for this small shared state, and keeps the implementation straightforward to explain. React Query is used separately for remote API state and caching.

**Why AsyncStorage:** Favorites only need a small list of Pokémon IDs and names. AsyncStorage is an Expo-compatible on-device store that survives app restarts without a backend or account. Favorite UI updates optimistically; storage writes are queued to preserve the order of rapid toggles.

## Folder guide

- `app/` — Expo Router routes, tabs, and the detail page.
- `components/` — reusable Pokémon cards, type chips, and stat bars.
- `context/` — shared and persisted favorites state.
- `services/` — PokéAPI requests and response parsing.
- `constants/` and `hooks/` — color tokens and the theme hook.

## Implementation decisions and assumptions

- The attached brief mentioned a Figma reference, but no Figma link or design file was included. The app uses a warm, paper-like background, restrained Poké Ball red, clear type colors, and card-based browsing as a reasonable mobile interpretation.
- Search filters only the currently loaded pages, as required; it does not trigger a remote search.
- Favorites store only each Pokémon's ID and name. The image URL is derived from the ID, avoiding a duplicate copy of Pokémon details.
- The public API is the only network dependency. There is no login or backend service.

## Known limitations

- Pokémon artwork and details require an internet connection; only favorites persist offline.
- Search covers loaded Pokémon only. Load more pages to expand its search scope.
- No Figma file was available for pixel-level comparison.
- This selected Expo deliverable does not meet a requirement for a native Flutter/Dart source repository.

## If more time were available

- Add automated tests for pagination parsing, malformed API responses, and rapid favorite toggles.
- Add offline caching for previously opened Pokémon and a more complete network/offline indicator.
- Compare against the original Figma once its link or export is available.
- If Flutter/Dart is mandatory for evaluation, port the completed flows and shared-state behavior into the target Flutter repository.

## Suggested meaningful commit sequence

1. Add PokéAPI models and paginated API service.
2. Build Browse list, search, and pagination states.
3. Add Pokémon detail route and stats presentation.
4. Add shared favorites context and local persistence.
5. Add Favorites tab, empty states, and retry handling.
6. Finish documentation and run formatting and static checks.
