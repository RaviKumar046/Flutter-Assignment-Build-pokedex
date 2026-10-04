# Flutter Pokédex

A small, null-safe Flutter app that browses Pokémon from the public PokéAPI.
It keeps the app's core responsibilities separated into models, an API service,
ChangeNotifier providers, screens, and reusable widgets.

## Features

- Loads Pokémon in API pages of 20 and requests more as the list is scrolled.
- Searches the Pokémon currently loaded on the device; it does not send search
  requests to the server.
- Opens a detail screen with official artwork, types, height, weight, abilities,
  and all returned base stats.
- Shows friendly initial-load and pagination errors with retry actions.
- Saves favorites locally and synchronizes favorite buttons on the list, detail,
  and Favorites tab immediately.
- Handles empty search results and an empty Favorites tab.
- Uses a shared in-memory detail cache to avoid repeat detail requests.

## Screens

1. **Pokédex:** searchable, paginated grid of Pokémon cards.
2. **Pokémon detail:** artwork, type badges, measurements, abilities, stats, and
   the shared favorite button.
3. **Favorites:** locally saved Pokémon, with the same card and favorite state.

## Run the app

Install Flutter, then from this directory run:

```sh
flutter pub get
flutter run
```

To run the automated checks:

```sh
dart format .
flutter analyze
flutter test
```

For a browser build:

```sh
flutter build web
```

Android builds additionally require an installed Android SDK and accepted
Android licenses. iOS builds require macOS and Xcode.

## API

The app uses the unauthenticated public API at
[`https://pokeapi.co/api/v2/`](https://pokeapi.co/api/v2/). The initial list
request uses `pokemon?limit=20&offset=0`, and subsequent requests follow the
API's `next` URL. A selected Pokémon is loaded from `pokemon/{id}`.

## State management and persistence

`provider` and `ChangeNotifier` were selected because the app needs one small
shared state that multiple screens can observe. `FavoritesProvider` is the
single source of truth for favorite IDs and names. Each screen reads and toggles
that same provider, so a change notifies the list, detail route, navigation
badge, and Favorites tab without manual refresh.

`shared_preferences` persists only the favorite Pokémon IDs and names as a
small JSON value. It is appropriate for this lightweight, device-local
collection; the app does not cache the complete Pokédex. State changes are
applied in memory immediately, while serialized writes keep rapid toggles from
persisting out of order.

## Folder structure

```text
lib/
  app.dart
  main.dart
  models/
  providers/
  screens/
  services/
  utils/
  widgets/
test/
  app_flow_test.dart
  favorites_provider_test.dart
  models_test.dart
  provider_test.dart
  fakes/
```

- `models/` parses the list and detail responses.
- `services/` owns HTTP requests, timeouts, status validation, and API errors.
- `providers/` contains paginated list/detail caching and shared favorites.
- `screens/` contains the list, detail, and Favorites navigation surfaces.
- `widgets/` contains shared cards, artwork, type badges, stat bars, and states.

## Design assumptions

The workspace included the written assignment brief, but no Figma file,
screenshot, or Figma URL. The UI therefore uses a simple mobile-first Pokédex
layout: a coral header with search, a pastel two-column card grid, a detail
hero, and a bottom navigation bar. It follows the brief's hierarchy and spacing
goals but cannot be compared pixel-for-pixel with the absent Figma reference.

Pokémon artwork is loaded from the PokeAPI sprites repository. If an image is
unavailable, the UI displays a built-in icon instead.

## Known limitations and future improvements

- Search intentionally filters only the pages already loaded, as required.
- PokéAPI and its artwork need an internet connection; list/detail results are
  not cached offline.
- Favorites are local to this installation and do not sync between devices.
- With more time, the app could add offline detail caching, accessibility review
  on physical devices, and a visual pass against the actual Figma file.