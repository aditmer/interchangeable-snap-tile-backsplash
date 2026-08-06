# MVP CAD

`snap_tile_mvp.scad` is a parameterized OpenSCAD source for issues #2-#5. It uses
millimetres and exports one part through the `part` selector:

| Part | Use |
| --- | --- |
| `grid` | One modular mounting-grid section |
| `carrier` | One structural 3 x 6 inch tile carrier |
| `carrier_assembly` | Non-printable carrier plus inserted clip preview |
| `flex_clip` | Integral-flexure comparison concept |
| `spring_clip` | Replaceable clip concept |
| `coupon` | Three clearance variants: 0.20, 0.35, 0.50 mm |
| `hook_coupon` | Upper hook/receiver clearance variants |
| `latch_coupon` | Lower latch/clip clearance variants |
| `registration_coupon` | Section registration key/slot variants |
| `panel` | Nine grid sections for layout review |

Example export:

```sh
openscad -o build/grid-A1.stl -D 'part="grid"' cad/snap_tile_mvp.scad
```

The source is a geometry baseline, not a material, heat, moisture, or installation
approval. Record printer settings and measured dimensions in `docs/test-results/`.
