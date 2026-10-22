# Kivora Design System & Visual Specification

This document records the visual tokens extracted from `Kivora_Complete_App_Designs-1(1).pdf` and established provisional tokens.

---

## 1. Extracted Color Palette (Authoritative from Designs)

Visual inspection of the PDF reveals a refined healthcare/educational/enterprise aesthetic combining deep teal-blue tones with clean neutral backgrounds, high-contrast typography, and explicit status indicators.

### Primary Brand Palette
- **Primary Brand / Action (Teal-Cyan)**: `#0D9488` / `#0F766E` (Darker active: `#115E59`)
- **Primary Accent / Brand Light**: `#E6FFFA` / `#CCFBF1` (Used on icon backdrops, selected tabs, and badges)
- **Primary Deep (Header / Logo Text)**: `#0F172A` (Navy/Slate)
- **Secondary Brand (Slate Blue)**: `#334155`

### Surface & Background Tokens
- **Application Canvas Background**: `#F8FAFC` (Light Slate Canvas)
- **Surface / Card Background**: `#FFFFFF` (Pure White)
- **Muted Surface Background**: `#F1F5F9` (Light Grey input & tag backgrounds)
- **Dividers & Borders**: `#E2E8F0`

### Semantic Feedback Tokens
- **Success / Passed / Present**:
  - Text & Icon: `#10B981` (Emerald 500) / `#059669` (Emerald 600)
  - Surface Background: `#ECFDF5` (Emerald 50)
  - Border: `#A7F3D0`
- **Warning / Late / Needs Review / Half-Day**:
  - Text & Icon: `#F59E0B` (Amber 500) / `#D97706` (Amber 600)
  - Surface Background: `#FFFBEB` (Amber 50)
  - Border: `#FDE68A`
- **Destructive / Error / Absent / Failed**:
  - Text & Icon: `#EF4444` (Red 500) / `#DC2626` (Red 600)
  - Surface Background: `#FEF2F2` (Red 50)
  - Border: `#FECACA`
- **Information / System Notice**:
  - Text & Icon: `#0284C7` (Sky 600)
  - Surface Background: `#F0F9FF` (Sky 50)
  - Border: `#BAE6FD`

### Text & Content Hierarchy
- **Text Primary (Headings, titles, labels)**: `#0F172A` (Slate 900)
- **Text Secondary (Subtitles, body, time)**: `#475569` (Slate 600)
- **Text Muted (Placeholders, inactive indicators)**: `#94A3B8` (Slate 400)
- **Text Inverted (Button text on primary backgrounds)**: `#FFFFFF`

---

## 2. Typography Specification

The design utilizes a clean, modern, high-legibility geometric sans-serif (Inter / Outfit / SF Pro).

| Token | Weight | Size (sp/rem) | Line Height | Usage |
|---|---|---|---|---|
| `displayLarge` | Bold (700) | 28 / 1.75rem | 34px | Welcome headings, major stats |
| `headlineMedium` | SemiBold (600) | 22 / 1.375rem | 28px | Screen titles, card headers |
| `titleMedium` | Medium (500) | 16 / 1.0rem | 22px | Section labels, card titles |
| `bodyLarge` | Regular (400) | 15 / 0.9375rem | 22px | Main content, inputs |
| `bodyMedium` | Regular (400) | 14 / 0.875rem | 20px | Sub-text, list descriptions |
| `labelSmall` | Medium (500) | 12 / 0.75rem | 16px | Status chips, timestamps, tabs |

---

## 3. Elevation, Radius & Spacing Tokens

- **Border Radius**:
  - Input Fields: `12px`
  - Cards: `16px`
  - Buttons (Pill / Rounded): `24px` to `9999px` (Fully rounded pills are used for [Get Started ->], [Sign In ->], and action buttons in designs)
  - Chips & Badges: `8px`
- **Elevation**:
  - Level 0: None (Flat borders)
  - Level 1 (Cards): `0 1px 3px 0 rgba(0, 0, 0, 0.05), 0 1px 2px 0 rgba(0, 0, 0, 0.03)`
  - Level 2 (Floating Action / Nav): `0 4px 6px -1px rgba(0, 0, 0, 0.07)`
- **Spacing Grid**:
  - `space-1`: 4px
  - `space-2`: 8px
  - `space-3`: 12px
  - `space-4`: 16px
  - `space-6`: 24px
  - `space-8`: 32px
