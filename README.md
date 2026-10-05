🐾 Flutter Pokédex

Quick Link: https://flutter-assignment-builder--24ravi46.replit.app/

A mobile-first Flutter/Dart Pokédex application built as a take-home assignment using the public PokéAPI.

The app lets users browse Pokémon with pagination, search the Pokémon currently loaded in the app, view detailed information, and manage a locally persisted Favorites list with real-time synchronization across screens.

✨ Features

Pokémon List

Fetches Pokémon from the public PokéAPI.

Loads Pokémon in pages of 20.

Supports infinite scrolling / pagination using the API's next URL.

Searches and filters the Pokémon currently loaded on the device.

Displays Pokémon name, artwork/sprite, and ID.

Provides a favorite heart toggle on every Pokémon card.

Shows a loading state during the initial request.

Shows pagination loading feedback while more Pokémon are being fetched.

Provides a retry action when the API request fails.

Pokémon Details

Selecting a Pokémon opens a dedicated detail screen with:

Official artwork / sprite

Pokémon name and ID

Types with type-colored badges

Height

Weight

Abilities

Base stats, including HP, Attack, Defense, Special Attack, Special Defense, and Speed when returned by the API

Shared favorite toggle

Favorites

Favorites are a core part of the application:

Favorites are stored locally on the device.

A single shared state is used across the application.

Favorite changes are reflected immediately on the List, Detail, and Favorites screens.

A Pokémon can be favorited or unfavorited from multiple screens.

The Favorites tab displays only favorited Pokémon.

Favorites remain available after restarting the application.

An empty state is shown when there are no favorites.

Other Handling

The app also handles common edge cases such as:

Initial API failures

Pagination failures

Empty search results

Empty Favorites list

Missing Pokémon artwork

Slow or unavailable network responses

📱 Screens

1. Pokédex

A searchable, paginated grid of Pokémon cards with favorite controls.

2. Pokémon Details

A detailed view containing artwork, types, measurements, abilities, statistics, and the shared favorite control.

3. Favorites

A dedicated screen showing only favorited Pokémon and reflecting favorite changes in real time.

🎨 UI & Design

The application follows a clean, mobile-first Pokédex layout with:

Searchable header

Two-column Pokémon card grid

Pokémon artwork

Favorite heart controls

Type badges

Detail hero section

Base-stat visualization

Bottom navigation for the main screens

The assignment asks for reasonable visual fidelity to the referenced Figma design rather than a pixel-perfect reproduction.

🏗️ Architecture

The project uses a lightweight layered structure to keep API, state, models, and UI responsibilities separated.

lib/
│
├── app.dart
├── main.dart
│
├── models/
├── providers/
├── screens/
├── services/
├── utils/
└── widgets/

Application Flow

UI / Screens
     │
     ↓
Providers / Shared State
     │
     ↓
Services / API Layer
     │
     ↓
PokéAPI

The Favorites flow uses the same shared state across all relevant screens:

List Screen ──────┐
                  │
Detail Screen ────┼──→ FavoritesProvider ──→ Local Storage
                  │
Favorites Screen ─┘

This avoids maintaining separate favorite states on different screens.

🧩 Project Structure

lib/
│
├── app.dart
├── main.dart
│
├── models/
│   ├── pokemon.dart
│   └── pokemon_detail.dart
│
├── providers/
│   ├── favorites_provider.dart
│   └── pokemon_provider.dart
│
├── screens/
│   ├── home_screen.dart
│   ├── pokemon_detail_screen.dart
│   └── favorites_screen.dart
│
├── services/
│   └── pokemon_api.dart
│
├── utils/
│   └── ...
│
└── widgets/
    ├── pokemon_card.dart
    ├── artwork.dart
    ├── type_chip.dart
    ├── stat_bar.dart
    └── ...

test/
│
├── app_flow_test.dart
├── favorites_provider_test.dart
├── models_test.dart
├── provider_test.dart
└── fakes/

Folder Responsibilities

Folder

Responsibility

models/

Data models and JSON parsing

services/

API requests, timeouts, status validation, and API errors

providers/

Shared state, pagination, favorites, and detail caching

screens/

Main application screens and navigation

widgets/

Reusable UI components

utils/

Shared constants and helper utilities

test/

Automated tests and test fakes

🛠️ Tech Stack

Flutter

Dart

PokéAPI

Provider for state management

ChangeNotifier for shared reactive state

SharedPreferences for local favorite persistence

HTTP for REST API communication

The implementation keeps dependencies intentionally lightweight and uses Flutter's built-in widgets wherever practical.

🌐 API

This project uses the free, unauthenticated PokéAPI.

Base URL:

https://pokeapi.co/api/v2/

Pokémon List

GET /pokemon?limit=20&offset=0

The first request loads 20 Pokémon. Later requests follow the next URL returned by the API for pagination.

Pokémon Details

GET /pokemon/{id}

The selected Pokémon's detailed information is retrieved from the API and mapped into Dart models.

🔎 Search Behavior

Search filters the currently loaded Pokémon in memory.

For example, after loading multiple pages, searching for:

char

can return matching loaded Pokémon such as:

Charmander
Charizard

The search does not send a separate search request to the server.

❤️ State Management

Provider + ChangeNotifier

provider and ChangeNotifier are used for the application's shared state.

The main reason for this choice is that the app has a relatively small shared state requirement, with multiple screens needing to observe and modify the same favorite data.

FavoritesProvider is the single source of truth for favorite Pokémon.

When a favorite is toggled:

The in-memory state is updated immediately.

notifyListeners() updates listening widgets/screens.

The new favorite state is persisted locally.

This allows the List, Detail, Favorites screen, and related UI elements to remain synchronized without a manual refresh.

💾 Local Storage

shared_preferences is used to store favorite Pokémon locally.

Only the minimum required favorite information is persisted:

Pokémon ID
Pokémon Name

The application does not persist the entire Pokédex dataset.

On application startup, saved favorites are loaded into FavoritesProvider and made available to the UI.

⚡ Detail Caching

A shared in-memory detail cache is used during the current application session to reduce repeated requests for Pokémon details that have already been loaded.

This is an optimization only. Full offline caching of Pokémon data is not part of the application's core scope.

🔄 Pagination

Pokémon are loaded in batches of 20.

Initial request
     ↓
Pokémon 1–20
     ↓
Follow API `next`
     ↓
Pokémon 21–40
     ↓
Follow API `next`
     ↓
Pokémon 41–60

New results are appended to the existing list instead of replacing it.

Pagination also provides a separate loading/error state so that already loaded Pokémon remain visible while another page is being requested.

🚨 Loading, Error & Empty States

The application provides dedicated UI states for common situations.

Initial Loading

Loading Pokémon...

API Failure

Unable to load Pokémon
[ Retry ]

Empty Search

No Pokémon found

Empty Favorites

No favorite Pokémon yet ❤️

Missing Artwork

If the expected artwork is unavailable, the UI falls back to a built-in icon rather than failing the page.

🧪 Testing & Validation

Tests are included for important application behavior, including models, providers, favorites, and application flow.

Install dependencies

flutter pub get

Format the code

dart format .

Run static analysis

flutter analyze

Run tests

flutter test

Run the application

flutter run

Build for Web

flutter build web

Android builds require a configured Android SDK and accepted Android licenses. iOS builds require macOS and Xcode.

Run the validation commands above before submission and resolve any reported issues.

✅ Assignment Coverage

Requirement

Implementation

Pokémon list

✅

PokéAPI integration

✅

Pagination

✅

Search/filter

✅

Initial loading state

✅

API error handling

✅

Retry action

✅

Pokémon detail screen

✅

Artwork

✅

Types

✅

Height and weight

✅

Abilities

✅

Base stats

✅

Favorite toggle

✅

Local favorite persistence

✅

Single source of truth

✅

Real-time favorite synchronization

✅

Favorites screen

✅

Empty search state

✅

Empty Favorites state

✅

Detail caching

✅

README/documentation

✅

🔁 Main User Flows

Browse Pokémon

Open App
   ↓
Load Pokémon
   ↓
Browse Grid
   ↓
Scroll to Bottom
   ↓
Load Next Page

Search

Enter Search Query
        ↓
Filter Loaded Pokémon
        ↓
Display Matching Results

View Details

Tap Pokémon Card
        ↓
Open Detail Screen
        ↓
Fetch / Read Cached Detail
        ↓
Display Pokémon Information

Favorite Synchronization

List / Detail / Favorites
          ↓
   FavoritesProvider
          ↓
   Shared Application State
          ↓
    Local Persistence

📋 Scope

The application intentionally focuses on the core assignment requirements.

Out of Scope

Backend/server implementation

Authentication

Cloud synchronization of favorites

Full offline Pokédex caching

Automated CI/CD

App Store / Play Store release packaging

Large automated test coverage targets

These areas are not required for the core task.

⚠️ Known Limitations

Search only covers Pokémon that have already been loaded.

Pokémon list and detail data require an internet connection.

Full Pokémon data is not cached for offline browsing.

Favorites are local to the current device/installation.

Favorites are not synchronized between devices.

The visual implementation aims for reasonable fidelity to the referenced design rather than pixel-perfect reproduction.

🚀 Future Improvements

With additional time, the project could be extended with:

Offline detail/data caching

More advanced retry and network recovery handling

Accessibility review and improvements on physical devices

More polished animations and transitions

Broader automated test coverage

Additional performance optimization and image prefetching

A visual refinement pass against the original Figma reference

📦 Getting Started

Prerequisites

Install:

Flutter SDK

Dart SDK

Android Studio / Android SDK for Android development

Xcode for iOS development on macOS

Clone the repository

git clone https://github.com/RaviKumar046/Flutter-Assignment-Build-pokedex.git
cd Flutter-Assignment-Build-pokedex

Install dependencies

flutter pub get

Run the app

flutter run

📱 Platform Support

The project is designed primarily for portrait mobile layouts.

Supported / intended targets:

Android

iOS

Web build

Tablet and landscape-specific optimization are outside the assignment scope.

🌿 Git Workflow

The project is intended to be maintained using incremental Git commits rather than one large final commit.

A meaningful development history can follow a structure such as:

Initial Flutter project setup
        ↓
Add PokéAPI integration
        ↓
Implement Pokémon list
        ↓
Add pagination and search
        ↓
Add detail screen
        ↓
Implement shared favorites state
        ↓
Add local persistence
        ↓
Add Favorites screen
        ↓
Improve UI and error states
        ↓
Add tests and documentation

Commits should represent actual development work rather than artificial changes created only for appearance.

📄 Assignment Context

This project was developed for a Flutter Pokédex take-home assignment focused on:

Flutter/Dart fundamentals

API integration

State management

UI implementation

Real-time favorite synchronization

Code readability and structure

Git usage

Technical decision making

🔗 Repository

GitHub:

https://github.com/RaviKumar046/Flutter-Assignment-Build-pokedex

👨‍💻 Author

Ravi Kumar

Built with Flutter & Dart using the public PokéAPI.
