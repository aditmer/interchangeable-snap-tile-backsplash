# Prototype specification

## Baseline geometry

- Nominal visible tile: 3 × 6 inches (76.2 × 152.4 mm)
- Prototype panel: 3 columns × 3 rows minimum
- Target grout reveal: choose and document one value before printing; begin around 3 mm
- Grid: modular sections with registration keys between sections
- Tile cartridge: rigid top hooks, replaceable lower clip, concealed release feature

These are starting values, not final requirements. Actual dimensions must be updated from printed measurements and test results.

## CAD and print rules

- Keep all critical dimensions parameterized.
- Print a small fit coupon before a full panel.
- Mark every part with revision, material, and print orientation.
- Avoid relying on unsupported bridges for latch features.
- Design fillets at snap roots and remove sharp exposed edges.
- Record nozzle, layer height, wall count, infill, temperature, and post-processing.

## Revision naming

Use `component-rev`, for example `grid-A1`, `carrier-A1`, and `clip-A1`. A revision changes when geometry, material, or print process changes enough to affect test results.

## Acceptance sample

Do not call a revision a candidate until three independently printed copies fit the same grid and pass the basic install/remove test without cracking, binding, or accidental release.
