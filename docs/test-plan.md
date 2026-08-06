# Test plan

Record date, revision, material, printer/process, operator, setup, observations, and photos for every test.

## Required record

Use one dated record per test in `docs/test-results/`. Include issue number, revision,
material, printer/process, operator, setup, nominal and measured dimensions, observations,
photos, failure mode, and decision. A blank template is provided at
`docs/test-results/test-record-template.md`.

## Mechanical tests

- **Fit:** measure tile gaps, flushness, and misalignment across a 3 × 3 panel.
- **Install/remove:** five operators perform ten cycles each; note tool use, damage, and release difficulty.
- **Cycle life:** repeatedly cycle the clip until failure or a defined target; inspect for whitening, cracks, creep, and retention loss.
- **Retention:** apply a controlled outward pull and document the first release mode.
- **Neighbor replacement:** remove the center cartridge without disturbing the eight surrounding positions.
- **Grid attachment:** operate a full panel while monitoring wall fasteners, adhesive, and grid joints.

### Fit and tolerance coupons (issue #5)

Export `part = "coupon"` from `cad/snap_tile_mvp.scad`. Print the 0.20, 0.35, and
0.50 mm clearance variants without changing orientation. Measure the paired clearance
bars and printed-versus-nominal dimensions as a dimensional screen. Use separate
interface coupons for hook/latch deflection and registration key/slot fit, then confirm
final engagement on the assembled carrier/grid parts before selecting a revision.
Recommend a tolerance window only after all three variants have been inspected.

### Panel and usability (issues #6–#7)

Build nine grid sections and nine carriers using the selected coupon revision. Mark
every part revision. Remove and replace the center cartridge ten times, then have at
least five independent operators perform ten install/remove cycles each. Stop a test
for cracks, sharp edges, a pinch hazard, or an accidental release and record the stop
condition rather than continuing.

### Latch cycle life (issue #8)

Use a hand fixture or a documented manual procedure with a consistent insertion and
release path. Record the cycle count at first visible damage, retention loss, binding,
or failure. Inspect for whitening, cracks, creep, and loss of release access. Report a
replacement interval only when the failure criterion and sample revision are explicit.

## Environment and cleanability

- Expose coupons and assembled samples to representative humidity and water splash; inspect trapped moisture and dimensional change.
- Apply representative household cleaner only after confirming material compatibility; record staining, swelling, cracking, and loss of finish.
- Use a removable contamination surrogate to check whether joints, hooks, and recesses can be cleaned and visually inspected.

## Heat and aging

Use conservative, instrumented tests only after the mechanical prototype is stable. Compare temperatures against the manufacturer's material limits and local appliance-clearance requirements. Do not infer production safety from a short bench test.

## MVP exit criteria

All issues #1–#8 have linked records, three independently printed copies fit the same
grid, no unmitigated sharp-edge or accidental-release hazard remains, the latch has a
documented cycle result, and the team has a written decision on whether the design is
suitable for a larger prototype. This exit does not approve installation near heat,
water, food preparation, or electrical equipment.
