# Design and structure goals

## Enhanced prompt (design and structure request)

- **Design:** Replace the previous green/mint theme with a modern look using the Color Hunt palette (#4E56C0, #9B5DE0, #D78FEE, #FDCFFA). Make the UI feel **modern, smooth, and consistent** (gradients, rounded corners, subtle shadows, clear hierarchy) instead of an older, flat style.
- **Prompt:** The above is the clarified description of the design and structure work.
- **Structure:** Keep the `lib/` folder clean: fix file-name typos, keep related code grouped, and use a clear, consistent layout (e.g. constants, themes, screens, widgets).

## Palette (Color Hunt)

| Role      | Hex       | Usage                                   |
| --------- | --------- | --------------------------------------- |
| Primary   | `#4E56C0` | Headers, primary actions, nav selected  |
| Secondary | `#9B5DE0` | Accents, secondary buttons, gradients   |
| Tertiary  | `#D78FEE` | Highlights, list accents, soft fills    |
| Surface   | `#FDCFFA` | Light backgrounds, cards (with opacity)  |

## Implementation notes

- **Colors:** `lib/constants/colors.dart` defines `palettePrimary`, `paletteSecondary`, `paletteTertiary`, `paletteSurface`. Design system and theme use these.
- **Gradients:** Home header and settings-style secondary buttons use a linear gradient (primary → secondary).
- **Theme:** `lib/themes/theme.dart` uses the new palette for `ColorScheme`, app bar, bottom nav, sliders, and cards.
- **Structure:** Widget file names use correct spelling (e.g. `delete_downloaded_translations_button.dart`, `selected_translations_card.dart`).
