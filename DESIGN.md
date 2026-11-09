---
name: Project Starter Lavish
description: Quiet, Apple-grade review surfaces for agent work, in light and dark.
colors:
  ground-light: "#ffffff"
  ground-dark: "#000000"
  surface-dark: "#0e0e10"
  fill-light: "#f5f5f7"
  fill-dark: "#1c1c1e"
  ink-light: "#1d1d1f"
  ink-dark: "#f5f5f7"
  ink-secondary-light: "#6e6e73"
  ink-secondary-dark: "#a1a1a6"
  blue-light: "#0071e3"
  blue-dark: "#2997ff"
  pink-light: "#e2468f"
  pink-dark: "#ff6fb0"
  core-blue: "#0068e0"
  core-pink: "#cc3d88"
typography:
  display:
    fontFamily: "-apple-system, BlinkMacSystemFont, SF Pro Display, Helvetica Neue, Segoe UI, system-ui, sans-serif"
    fontSize: "4.5rem"
    fontWeight: 700
    lineHeight: 1.04
    letterSpacing: "-0.035em"
  headline:
    fontFamily: "-apple-system, BlinkMacSystemFont, SF Pro Display, Helvetica Neue, Segoe UI, system-ui, sans-serif"
    fontSize: "2.5rem"
    fontWeight: 700
    lineHeight: 1.1
    letterSpacing: "-0.028em"
  title:
    fontFamily: "-apple-system, BlinkMacSystemFont, SF Pro Text, Helvetica Neue, Segoe UI, system-ui, sans-serif"
    fontSize: "19px"
    fontWeight: 600
    lineHeight: 1.3
    letterSpacing: "-0.02em"
  body:
    fontFamily: "-apple-system, BlinkMacSystemFont, SF Pro Text, Helvetica Neue, Segoe UI, system-ui, sans-serif"
    fontSize: "17px"
    fontWeight: 400
    lineHeight: 1.5
    letterSpacing: "-0.012em"
  caption:
    fontFamily: "-apple-system, BlinkMacSystemFont, SF Pro Text, Helvetica Neue, Segoe UI, system-ui, sans-serif"
    fontSize: "13px"
    fontWeight: 500
  code:
    fontFamily: "ui-monospace, SF Mono, Menlo, Consolas, monospace"
    fontSize: "0.84em"
rounded:
  inline: "6px"
  note: "16px"
  panel: "20px"
  pill: "999px"
spacing:
  gutter: "24px"
  column-gap: "28px"
  section: "96px"
  max-width: "1080px"
components:
  chip:
    backgroundColor: "rgb(0 113 227 / 0.08)"
    textColor: "{colors.blue-light}"
    rounded: "{rounded.pill}"
    padding: "6px 13px"
  panel:
    backgroundColor: "{colors.ground-light}"
    rounded: "{rounded.panel}"
    padding: "32px"
  note:
    rounded: "{rounded.note}"
    padding: "18px 22px"
  segmented-control:
    backgroundColor: "{colors.fill-light}"
    rounded: "{rounded.pill}"
    padding: "2px"
---

# Design System: Project Starter Lavish

Source of truth for values is `.lavish/theme.css`; this file explains intent. `.lavish/theme-preview.html` shows every component in both appearances.

## Overview

Read-mode review surfaces that feel like an Apple product page: white or true-black grounds, one blue accent, San Francisco type, hairline structure, and a faint blue-to-pink wash. The page frames the content and then gets out of the way.

## Colors

### Primary

Apple blue carries links, chips, step numbers, focus rings, and diagram edges: `#0071e3` in light, `#2997ff` in dark.

### Secondary

Pink appears only as a gradient partner to blue: the top-of-page wash, `.lv-note` backgrounds, and the gradient core node in diagrams. It is never a text, border, or button color.

### Neutral

Ink `#1d1d1f` / `#f5f5f7`, secondary ink `#6e6e73` / `#a1a1a6`, fills `#f5f5f7` / `#1c1c1e`, hairlines at 8% / 10% alpha.

### Named Rules

- **One light-dark() token per role.** Every color is defined once in `:root` with `light-dark()`; `data-theme="light|dark"` pins a mode by setting `color-scheme`.
- **Slight means slight.** Wash alphas stay at or below 0.2; if pink is noticeable before the headline, it is too strong.

## Typography

The system stack resolves to SF Pro on Apple devices. Display 700 with tight tracking (never below -0.04em); body 17px/1.5 with a 62–75ch measure; secondary copy in secondary ink, never lighter.

### Hierarchy

Title (`.lv-title`) → section heading (`.lv-h2`) → item title (h3, 19px/600) → body → caption (13px). No eyebrows, kickers, or uppercase tracked labels above headings.

## Layout

A 1080px column with 24px gutters (16px under 520px), sections separated by a single hairline and 56–96px of space. Container queries on `.lv-page` drive responsiveness: the hero stacks under 860px, column groups under 640px. Tables scroll horizontally inside their own wrapper.

## Elevation & Depth

Depth is mostly hairlines. Panels add a soft offset shadow in light mode and a 5% white top highlight in dark mode. The sticky nav is the only translucent material (saturate 180%, blur 20px), because content scrolls beneath it.

## Shapes

Rounded rectangles: 20px panels and tables, 16px notes, 14px diagram nodes, 6px inline code, full pills for chips and the segmented control. Circles only for step numbers and the diagram core.

## Components

- **Nav (`.lv-nav`)**: brand, section links, Auto/Light/Dark segmented control (`theme.js`, remembered in localStorage).
- **Hero (`.lv-hero`)**: title, lede, chips, and an optional figure.
- **Columns (`.lv-cols`)**: hairline-divided groups that replace boxed card grids.
- **Steps (`.lv-steps`)**: numbered list for real sequences only.
- **Table (`.lv-table-wrap` + `.lv-table`)**: fill header, row hairlines, first column in primary ink.
- **Note (`.lv-note`)**: blue-to-pink tinted callout for trust or caveat statements.
- **Diagram (`.lv-diagram` + `d-*` classes)**: inline SVG; nodes on surface with hairline stroke, blue edges with chevron heads, dashed neutral edges for optional paths, one gradient core node at most.

## Do's and Don'ts

- Do link `theme.css` and `theme.js` from every page in `.lavish/`; do not add CDN frameworks.
- Do keep every claim tied to a repository file.
- Don't use gradient text, glass as decoration, colored side borders, eyebrows, or section numbers that carry no information.
- Don't introduce a second accent color; pink stays inside gradients.
