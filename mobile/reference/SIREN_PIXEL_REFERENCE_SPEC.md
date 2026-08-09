# SIREN — PIXEL REFERENCE IMPLEMENTATION SPEC

Use this file together with `siren-reference.png` and `siren_ui_reference_v3.html`.

## Hard rule
Do NOT redesign. Treat the supplied image as a measurable UI specification.

Reference canvas: **1712 × 919 px**

Detected phone frames:

| Screen | X | Y | Width | Height |
|---|---:|---:|---:|---:|
| 01 — Ana Sayfa / Navigasyon | 73 | 26 | 462 | 859 |
| 02 — Ana Sayfa / Dashboard | 615 | 26 | 466 | 865 |
| 03 — Rota Planlama | 1163 | 26 | 467 | 867 |

## Scaling rule

For implementation, preserve the reference proportions. Do NOT copy desktop pixel values blindly into a mobile viewport.

Use:

`scale = min(viewportWidth / referencePhoneWidth, viewportHeight / referencePhoneHeight)`

Then derive component sizes from the reference proportions.

## Screen 01 — measured regions

- Status / Dynamic Island: x=132 y=43 w=343 h=40
- Top Bar: x=101 y=95 w=389 h=48
- Weather Card: x=369 y=153 w=120 h=97
- Map Controls: x=100 y=202 w=58 h=272
- Müra Marker: x=101 y=492 w=77 h=43
- Map Zoom: x=449 y=572 w=40 h=118
- Scale: x=105 y=637 w=74 h=43
- Primary CTA: x=103 y=694 w=387 h=57
- Bottom Navigation: x=87 y=762 w=426 h=78

## Screen 02 — measured regions

- Status / Dynamic Island: x=673 y=43 w=341 h=40
- Header: x=634 y=96 w=389 h=50
- Boat Card: x=632 y=167 w=268 h=138
- Speed/GPS Card: x=906 y=167 w=117 h=138
- Weather Card: x=632 y=315 w=391 h=101
- Last Route Card: x=632 y=429 w=391 h=140
- Nearby Marks Card: x=632 y=580 w=391 h=157
- Bottom Navigation: x=632 y=768 w=391 h=72

## Screen 03 — measured regions

- Status / Dynamic Island: x=1218 y=43 w=344 h=40
- Header: x=1180 y=96 w=431 h=49
- Route Map: x=1168 y=146 w=440 h=411
- Map Controls: x=1168 y=214 w=60 h=215
- Route Summary: x=1408 y=157 w=187 h=251
- Scale: x=1168 y=475 w=73 h=38
- Route Points: x=1167 y=568 w=440 h=192
- Bottom Actions: x=1167 y=785 w=441 h=48

## Visual rules

1. Dark marine background dominates.
2. Cards are translucent/dark navy, never white.
3. Borders are thin and low-contrast.
4. Primary navigation action is green.
5. Secondary action is electric blue.
6. Active bottom-nav item is blue; inactive items are muted gray.
7. No emoji as UI icons.
8. Use SVG/line icons with consistent 1.5–2 px stroke.
9. Fish imagery must use separate assets for Çipura, Levrek and Mercan.
10. Map overlays must not obscure the map.
11. Keep generous but controlled spacing.
12. Do not inflate typography.
13. Do not replace the map with a generic dashboard panel.
14. Do not create a generic card grid.
15. Do not invent new visual language.

## QA requirement

For every implemented screen, compare a screenshot against the reference at the same aspect ratio.

Check:
- outer geometry
- top safe area
- header baseline
- card bounds
- CTA height
- bottom navigation height
- icon alignment
- text baseline
- map overlay position
- border radius
- border opacity
- spacing

If an element is visibly displaced, correct the CSS/layout instead of compensating with unrelated margins.
