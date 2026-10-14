# Doji (recreation): native iOS app

This is a native **SwiftUI** recreation of the **Doji: Try on designer fashion** iOS app. It follows the screens and user flow that Doji has on Mobbin.

> The Mobbin version page given as the reference (`apps/doji-ios-…/998a80d5-…/flows`) is behind a login, so it couldn't be opened directly. The screens were gathered through the Mobbin connector instead. The connector cannot filter by app version, so this build follows the **current Doji design**: a "9.41" status bar, *For You / Following / Shop*, and a five-icon tab bar. All 30 of the top results for "Doji — Try on designer fashion" come from that design.

## Run it

1. On a Mac with **Xcode 16 or newer**, open `Doji.xcodeproj`.
2. Pick an iPhone simulator (iOS 17 or newer) and press **Run**.
3. To install on a real iPhone, choose your Team under *Signing & Capabilities*.

No packages, keys or backend are needed. All the data is sample data (see `Doji/Models/MockData.swift`).

## What's included

| Area | Screens (newer Doji design) |
|---|---|
| **Sign up** | Welcome carousel → Phone number → Enter the code (30s resend) → Email |
| **Likeness** | Create your likeness → Take 6 selfies → "For best results" tips sheet → Selfie camera (live front camera, lighting pill, n/6) → Turn on notifications |
| **Taste & profile** | Select 3+ brands (search, chips) → Create a username → Set your profile pic (Photos picker) → Find all your friends |
| **Friends** | Contacts primer → Invite your friends (real device contacts) → Invite With (Messages / WhatsApp) |
| **Home** | For You feed · Following (empty state → Connect Contacts) · Shop grid with ♡ and the "Saved to Favorites · View" toast |
| **Look** | Look detail (creator +follow, like, remix, share, more) · In the Look sheet · Tried on by sheet · Try On → "New look ready" |
| **New Looks** | Review queue with a badge → Discard / Save → Save to Profile and Collections (+ New Collection) |
| **Product** | Image pager · Buy ↗ (in-app Safari) · Try On · More to Explore |
| **Create Look (+)** | Outfit slots with lock/remove · Select a Top / Bottoms… picker with chips · Style Me (skeleton then auto-fill) · Try on |
| **Search** | Search home (Recently Viewed, Featured Collections, Top Creators, Brands For You) · Suggestions · Results (All/Looks/Products, Category, Brand) · Filters sheet (Type, Brand, Sort, Department) |
| **Collections** | Featured collection (Follow, Add Your Look → Add to … sheet → toast) · Your collection with the Add/Organize/Edit bar · Favorites |
| **Activity** | Try-on notifications with unread dots |
| **Profile** | Public/Private tabs · Collections · Looks · Edit Profile · Update Likeness · Creator profiles · Share Look (Stories/Share/Link/Save) |
| **Settings** | Safari extension card · Update Likeness · Edit Profile · Your Brands · Shopping Preference (Menswear/Womenswear) · Support links · Log Out → back to Welcome |

## Design tokens

- **Type:** everything is set in a serif. Doji's own typeface wasn't provided, so Apple's built-in **New York** serif (`.serif` design) stands in. Change it in one place: `Font.doji(_:)` in `Doji/Theme/Theme.swift`.
- **Colors:** white background, near-black ink `#0A080A`, gray secondary text, `#F2F1F3` soft fills, red unread dots and badges.
- **Shapes:** pill buttons (black primary, gray secondary, outlined), hairline dividers, 28pt sheet corners.

## Images (asset slots)

No Doji assets were supplied, and nothing from the Mobbin screenshots is bundled with the app. Every image is a **named slot**: until a matching image exists in `Doji/Assets.xcassets`, the app shows a neutral gray placeholder. To use real photos you own or have licensed, drag them into the asset catalog with these names:

| Slot name | Used for |
|---|---|
| `look_l01` … `look_l12` | Full-length look photos (feeds, look detail, grids) |
| `product_p01` … `product_p28` | Product packshots (Shop, pickers, In the Look). Extra pager images: `product_pXX_2` … `_5` |
| `avatar_<username>`, `avatar_me` | Profile pictures (`avatar_me` is replaced by the photo the user uploads) |
| `tryon_<lookID>`, `tryon_new` | Generated try-on images in New Looks |
| `collection_<id>` | Featured collection covers (`made-in-korea`, `alt-wedding`, `music-fashion`) |
| `welcome_1`, `welcome_3` | Welcome carousel |
| `likeness_intro`, `selfies_model`, `selfie_example_1…6` | Likeness onboarding |
| `tip_lighting_bad/good`, `tip_glasses_bad/good` | Selfie tips sheet |
| `friends_1…6`, `following_empty`, `brands_for_you` | Friends and Brands For You art |

You'll also need an app icon (1024×1024) in `AppIcon`.

## Not available in the reference, so not invented

These were missing from the Mobbin data I could reach. I left them out or kept them minimal rather than guessing:

- **Welcome carousel page 2** (of 3) and **selfie tip page 2** (of 3): only the first and last pages exist on Mobbin.
- **Selfie poses 2–6:** only "Look straight ahead" was captured, so it's reused for every shot.
- **Two full-length photo capture screens** (implied by the notifications screen).
- **Account**, **Organize**/**Edit collection**, **Add Product (paste a link)**, **Recently Viewed ›**, **Top Creators ›**, and the Activity queue screens. The buttons are there but don't do anything yet.
- **Real URLs** for Terms, Privacy, Contact, the Safari extension and retailer "Buy" pages. These are `example.com` placeholders in `AppLinks` (`Doji/Onboarding/SignUpViews.swift`).

## What this MVP does *not* do (it needs a backend)

- **Phone verification:** any 6-digit code is accepted.
- **Likeness generation and try-on rendering:** the AI image step. Try On queues a result that shows the slot image.
- **Real catalog, feeds, follows, saved data:** everything lives in memory and resets when the app relaunches.

## Project layout

```
Doji.xcodeproj
Doji/
  App/            DojiApp, root switch (onboarding ↔ main)
  Theme/          colors, spacing, serif font helper
  Models/         models, sample data, AppState (app state)
  Components/     buttons, image slots, toast, chips, flow layout, headers
  Onboarding/     sign up, likeness, brands, profile pic, friends/invite
  Home/           tab bar, router, For You / Following / Shop
  Look/           look detail, sheets, New Looks, share, product detail
  Create/         Create Look + product picker
  Search/         search, results, filters, featured collections
  Activity/       activity feed
  Profile/        profile, collections, creator profile, settings, preference
```
