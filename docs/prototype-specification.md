# Prototype specification

## Baseline geometry (grid-A1 / carrier-A1 / clip-A1)

- Nominal visible tile: 3 × 6 inches (76.2 × 152.4 mm)
- Nominal tile pitch: 79.2 × 155.4 mm
- Target grout reveal: 3.0 mm
- Grid section: one tile position, 79.2 × 155.4 mm overall
- Grid wall: 4.0 mm nominal, with 1.5 mm perimeter ribs
- Upper hook: 8.0 mm engagement depth with a 30° lead-in
- Lower latch datum: 12.0 mm above the carrier bottom
- Release access: 10.0 mm finger recess below the carrier's lower edge
- Coupon tolerance variants: 0.20, 0.35, and 0.50 mm clearance
- Prototype panel: 3 columns × 3 rows minimum

These values are a printable baseline, not final requirements. Measure printed parts and
update the revision when geometry, material, or process changes affect test results.
The OpenSCAD source in `cad/snap_tile_mvp.scad` is the source of truth for these values.

## CAD and print rules

- Keep all critical dimensions parameterized.
- Print a small fit coupon before a full panel.
- Mark every part with revision, material, and print orientation.
- Avoid relying on unsupported bridges for latch features.
- Design fillets at snap roots and remove sharp exposed edges.
- Record nozzle, layer height, wall count, infill, temperature, and post-processing.
- Use the `part` selector in `cad/snap_tile_mvp.scad` to export one named part at a time.
- Print grid and carrier revisions in the same material for interface tests; do not infer
  material or heat performance from geometry-only coupons.

## Revision naming

Use `component-rev`, for example `grid-A1`, `carrier-A1`, and `clip-A1`. A revision changes when geometry, material, or print process changes enough to affect test results.

## Acceptance sample

Do not call a revision a candidate until three independently printed copies fit the same grid and pass the basic install/remove test without cracking, binding, or accidental release.
