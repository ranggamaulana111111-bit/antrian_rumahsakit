# TravelPack — AGENTS.md

## Dev commands

```bash
flutter run              # run app on connected device/emulator
flutter test             # run all tests
flutter analyze          # static analysis (linter)
flutter build apk        # Android release build
flutter pub get          # install dependencies
```

## Project overview

TravelPack adalah aplikasi Flutter untuk mengelola daftar barang bawaan perjalanan. Pengguna dapat membuat checklist packing, mengelompokkan barang per kategori, melihat progres visual, dan CRUD via SQLite.

## Architecture

- **Entrypoint:** `lib/main.dart` → `TravelPackApp` di `lib/app.dart`
- **SDK:** `^3.11.4`, single package, multi-platform (android, ios, linux, macos, web, windows)
- **Linting:** `package:flutter_lints/flutter.yaml` via `analysis_options.yaml`
- **Dependencies:** `sqflite`, `path`, `intl`, `cupertino_icons`
- **No state management library** — `StatefulWidget` + SQLite query per page (scope sesuai)

### Layer structure

```
lib/
├── main.dart                    # runApp(TravelPackApp())
├── app.dart                     # MaterialApp + routing + theme
├── core/
│   ├── theme/
│   │   ├── app_colors.dart      # Color constants
│   │   ├── app_text_styles.dart # Typography
│   │   └── app_theme.dart       # ThemeData global
│   ├── constants/
│   │   ├── app_constants.dart   # App name, DB name, credentials
│   │   └── categories.dart      # Category + default items + priorities
│   └── utils/
│       └── validators.dart      # Form validation helpers
├── data/
│   ├── database/
│   │   └── database_helper.dart # Singleton SQLite helper
│   ├── models/
│   │   └── packing_item.dart    # PackingItem model + toMap/fromMap/copyWith
│   └── repositories/
│       └── packing_repository.dart # Business logic + validasi + timestamp
├── pages/
│   ├── splash/splash_screen.dart
│   ├── login/login_page.dart
│   ├── home/home_page.dart
│   ├── packing_list/packing_list_page.dart
│   ├── detail/packing_item_detail_page.dart
│   ├── add_edit/add_edit_packing_item_page.dart
│   └── profile/profile_page.dart
└── widgets/
    ├── app_drawer.dart
    ├── stat_card.dart
    ├── packing_item_card.dart
    ├── category_badge.dart
    ├── priority_badge.dart
    ├── progress_bar.dart
    ├── empty_state.dart
    ├── loading_widget.dart
    └── confirmation_dialog.dart
```

### Data flow

```
User Action → Page (StatefulWidget) → DatabaseHelper → SQLite
                                       ↓
Page ← FutureBuilder / setState ← PackingItem model
```

Atau via Repository (rekomendasi untuk validasi & business logic):

```
User Action → Page → PackingRepository → DatabaseHelper → SQLite
```

## Routing (lib/app.dart)

| Route | Page | Arguments |
|---|---|---|
| `/splash` | SplashScreen | — |
| `/login` | LoginPage | — |
| `/home` | HomePage | — |
| `/packing-list` | PackingListPage | — |
| `/detail` | PackingItemDetailPage | `int itemId` |
| `/add` | AddEditPackingItemPage | — |
| `/edit` | AddEditPackingItemPage | `int itemId` |
| `/profile` | ProfilePage | — |

Named push: `Navigator.pushNamed(context, '/detail', arguments: item.id)`

## Database

**SQLite** via `sqflite` + `path`. Singleton `DatabaseHelper` di `lib/data/database/database_helper.dart`.

Tabel `packing_items`:

| Kolom | Tipe | Notes |
|---|---|---|
| `id` | INTEGER PK AUTOINCREMENT | |
| `nama_barang` | TEXT NOT NULL | |
| `kategori` | TEXT NOT NULL | Dokumen / Pakaian / Peralatan Mandi / Elektronik / Obat-obatan |
| `prioritas` | TEXT NOT NULL | Tinggi / Sedang / Rendah |
| `tanggal_perjalanan` | TEXT NOT NULL | ISO date (yyyy-MM-dd) |
| `status_packing` | INTEGER DEFAULT 0 | 0 = Belum, 1 = Sudah |
| `catatan` | TEXT | Opsional |
| `created_at` TEXT NOT NULL | ISO timestamp |
| `updated_at` TEXT NOT NULL | ISO timestamp |

Methods di `DatabaseHelper`: `insert`, `getAll` (orderBy), `getById`, `getByCategory`, `getByStatus`, `search`, `update`, `delete`, `toggleStatus` (dengan updated_at), `getStats`, `getCountByCategory`, `bulkInsert`, `deleteByCategory`, `clearAll`.

**Repository** — `PackingRepository` (`lib/data/repositories/packing_repository.dart`) membungkus `DatabaseHelper` dengan validasi, auto-timestamp, dan business logic:
- `addItem(...)` → sets createdAt + updatedAt
- `updateItem(...)` → sets updatedAt, validates existing
- `toggleStatus(id, currentStatus)` → juga update updated_at
- `addDefaultItemsForCategory(kategori)` → insert all default items from `categories.dart`
- `deleteByCategory`, `clearAll`, `getCountByCategory`

**Migration:** v1→v2 adds `updated_at` column (via `onUpgrade`).

## Color system

| Role | Color | Hex |
|---|---|---|
| Primary (Dark Slate) | ![](https://placehold.co/12/0F172A/0F172A) | `#0F172A` |
| Secondary (Slate) | ![](https://placehold.co/12/1E293B/1E293B) | `#1E293B` |
| Accent (Gold) | ![](https://placehold.co/12/D4AF37/D4AF37) | `#D4AF37` |
| Background | ![](https://placehold.co/12/F8FAFC/F8FAFC) | `#F8FAFC` |
| Surface / Card | ![](https://placehold.co/12/FFFFFF/FFFFFF) | `#FFFFFF` |
| Text Primary | ![](https://placehold.co/12/0F172A/0F172A) | `#0F172A` |
| Text Secondary | ![](https://placehold.co/12/475569/475569) | `#475569` |
| Success | ![](https://placehold.co/12/22C55E/22C55E) | `#22C55E` |
| Warning | ![](https://placehold.co/12/F59E0B/F59E0B) | `#F59E0B` |
| Error | ![](https://placehold.co/12/EF4444/EF4444) | `#EF4444` |

Defined in `lib/core/theme/app_colors.dart` — all widgets import from here, no hardcoded colors.

## Typography

Hierarchy: Display (34/w700) → Large Heading (28/w700) → Section Title (20/w600) → Body Text (16/w400) → Caption (13/w400).
Font family: Poppins (via ThemeData), defined in `app_text_styles.dart`.
Accent text style available via `AppTextStyles.accentText` / `accentLarge` (gold `#D4AF37`).

## Features

### Splash Screen
Logo + nama + loading, 2-3 dtk, auto navigate ke `/login`.

### Login
Username = "Nama Mahasiswa", Password = "NIM". Validasi kosong. Login sukses → SnackBar + navigate `/home`. Gagal → SnackBar error.

### Home Page
Stat cards: total, packed, unpacked, percentage. Daftar barang (ListView). FAB → `/add`. Tap item → `/detail`. Checklist toggle via checkbox.

### Packing Item Detail
Tampilkan semua field. Action: Edit → `/edit`, Hapus → confirm dialog → back to `/home`.

### Add/Edit Packing Item
Fields: Nama Barang (Text), Kategori (Dropdown), Prioritas (Dropdown → RadioButton), Tanggal (DatePicker), Status (Checkbox), Catatan (Text). Save → SQLite → back.

### Profile Page
Foto KTM, Nama Mahasiswa, NIM, Program Studi, Fakultas, Universitas, Logo UNPAM, Logo Sistem Informasi.

## Packing categories

Dokumen, Pakaian, Peralatan Mandi, Elektronik, Obat-obatan (with default items per category in `categories.dart`).

Priorities: Tinggi, Sedang, Rendah.

## Navigation

**Drawer** — reusable `AppDrawer` widget with menu: Home, Packing List, Profile, Logout.
All pages with AppBar use the same drawer instance.

## Required Flutter widgets

Container, Row, Column, Card, ListView, SingleChildScrollView, TextField, DropdownButton, RadioButton, Checkbox, DatePicker, Drawer, AppBar, FloatingActionButton.

## Required event handling

`onPressed`, `onTap`, `onChanged`, `showDialog`, `SnackBar` — every action must have visual feedback.

## Assets

```
assets/images/
├── travel_logo.png         # Aplikasi
├── splash_background.jpg   # Background splash
├── logo_unpam.png          # Profile
├── logo_si_serang.png      # Profile
└── foto_ktm.jpg            # Profile
```

Placeholder files exist. Replace with real images before release.

## Testing

- `test/widget_test.dart` — smoke test: app launches without error
- Run `flutter test` — no external services or fixtures
- Future tests per page using `flutter_test`

## Code rules

- **No const in ThemeData** — `AppTheme.lightTheme` is a getter, not const, because `ColorScheme.fromSeed` and `AppColors.*` are runtime values
- **No hardcoded colors** — always reference `AppColors.*`
- **No inline styles** — use `AppTextStyles.*` or theme defaults
- **No business logic in widgets** — database calls go through `DatabaseHelper` only
- **Reusable widgets** in `lib/widgets/` — `StatCard`, `PackingItemCard`, `CategoryBadge`, `PriorityBadge`, `ProgressBar`, `EmptyState`
- **Drawer is reusable** — single `AppDrawer` widget used across all pages
- **Avoid duplikasi kode, file terlalu besar, logic bercampur UI**
- **PackingItem** model with `toMap()`/`fromMap()`/`copyWith()` for SQLite serialization

## Design principles

Modern mobile, clean, travel-oriented, premium UX. Consistent border-radius (14-16), padding (16), shadow. Rounded corners, soft shadow, elegant cards. Target: professional travel app, not a campus project.

**Design system specifics (applied via `AppTheme.lightTheme`):**
- Cards: radius 20, soft shadow, spacious padding
- Buttons: full-width min 52 height, radius 16, premium feel
- Text fields: modern filled style, radius 16
- Checkbox/Radio: gold accent (`#D4AF37`) when selected
- FAB: gold accent background
- Drawer: rounded top-right/bottom-right corners (radius 20)
- SnackBar: primary dark background, floating behavior
- Progress indicator: gold accent track

