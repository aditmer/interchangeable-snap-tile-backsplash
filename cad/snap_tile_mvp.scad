// Interchangeable snap-tile backsplash MVP, grid-A1 / carrier-A1 / clip-A1.
// Units are millimetres. Export one part at a time with -D 'part="grid"' etc.

$fn = 48;

tile_w = 76.2;
tile_h = 152.4;
grout = 3.0;
pitch_w = tile_w + grout;
pitch_h = tile_h + grout;
wall = 4.0;
rib = 1.5;
hook_depth = 8.0;
hook_height = 4.0;
// Hook envelope height as printed: 1mm base offset + (hook_height - 1) body +
// 1mm lip rise = hook_height + 1. Receiver clearance must be sized to this full
// envelope, not just hook_height, or the lip collides with the roof.
hook_env_h = hook_height + 1.0;
clip_datum = 12.0;
release_depth = 10.0;
mount_z = wall;
registration_clearance = 0.25;
clearance = 0.35;
interface_y = pitch_h - rib - hook_depth;
hook_local_y = interface_y - rib + clearance;
hook_local_x_left = 16 - hook_depth / 2 + clearance;
hook_local_x_right = tile_w - 12 - hook_depth + clearance;
latch_tab_w = 20;
latch_tab_x0 = pitch_w / 2 - latch_tab_w / 2;
latch_rail_x0 = rib + 10;
latch_rail_x1 = pitch_w - rib - 10;
latch_rail_y0 = clip_datum;
latch_rail_depth = 3;
// Latch geometry: the tab is a single rigid, full-height block bonded directly
// into the carrier floor (durable, load-carrying, replaceable per-tile part);
// the compliance instead lives in a spring finger on the rail (see
// latch_rail()), which is the permanent, installed-once part.
ridge_reach = 0.9;
ridge_z0 = 3.0;
ridge_h = 1.0;
// Spring-finger geometry (rail side): a cantilever fixed only at its base
// (bonded, with real volumetric overlap -- see bond_eps above -- into the
// solid grid floor below z = wall) and free over its full height, thin in
// the X (lateral flex) direction, with an explicit finite-radius root fillet
// (see root_fillet_r above) instead of a square corner or a hull taper to a
// degenerate seam. Above the fillet band the section is uniform (finger_w);
// within the fillet band it is locally wider/stiffer, so the finger's actual
// worst-case strain is bounded above by treating the whole length as uniform
// finger_w, which is what the calculation below does.
//
// The ridge is built as a hull() from z = ridge_z0 to ridge_z0 + ridge_h, so
// its point of maximum X reach (ridge_reach) sits at the mid-height of that
// band, not at the finger's free tip. The strain-governing cantilever length
// is therefore the distance from the fixed root (z = wall) to that point,
// eff_l = ridge_z0 + ridge_h / 2 = 3.0 + 0.5 = 3.5 mm -- not hook_height
// (4.0 mm) as an earlier revision assumed.
//
// Clearing the ridge on insertion needs a lateral displacement of
// delta_pass = ridge_reach - 2 * clearance = 0.9 - 2 * 0.35 = 0.20 mm. For a
// cantilever of length eff_l = 3.5 mm and thickness finger_w = 1.0 mm
// (bending direction), the worst-case insertion fiber strain is
// eps_insert = 3 * finger_w * delta_pass / (2 * eff_l^2)
//            = 3 * 1.0 * 0.20 / (2 * 3.5^2) = 0.6 / 24.5 = 0.0245, i.e.
// ~2.45%, under the 3% allowable-strain target for printed PLA/PETG
// flexures, with margin held in reserve for the (unquantified by this beam
// formula) stress concentration at the root -- mitigated separately by the
// finite-radius root_fillet_r above. Removal is symmetric about the ridge's
// mid-height (same delta_pass, same eff_l), so eps_remove = eps_insert =
// ~2.45%.
//
// In the settled (fully seated) position the tab's undercut (see
// latch_tab()) relieves all but settle_interference = 0.05 mm of overlap, so
// the finger is left only lightly loaded rather than held open at the full
// delta_pass:
// eps_settled = 3 * finger_w * settle_interference / (2 * eff_l^2)
//             = 3 * 1.0 * 0.05 / 24.5 = 0.0061, i.e. ~0.61%.
//
// All three load states (insertion 2.45%, removal 2.45%, settled 0.61%) stay
// below the 3% allowable-strain target against the modeled section: eff_l
// and finger_w above are unaffected by root_fillet_r (a local, sub-length
// stiffening only) or by bond_eps (an extension into already-rigid material
// below the fixed root), so this recalculation matches the actual bonded,
// filleted geometry below.
finger_w = 1.0;
finger_gap = 0.5;
// Root fillet: an explicit, printable constant radius (not a hull taper to a
// near-zero seam) blending the isolation slot's lower corner into the floor.
// Above this band the slot is a constant finger_gap width, so the finger's
// cross-section is uniform (= finger_w) everywhere the beam calculation
// below actually applies; within the fillet band the section is locally
// wider (stiffer) than finger_w, so treating the whole eff_l (measured from
// z = wall, below) as uniform finger_w is a conservative over-estimate of
// strain, not an under-estimate.
root_fillet_r = 0.4;
// Bonding epsilon: the spring finger must have real volumetric overlap with
// the solid grid floor it's fixed to, and the ridge must have real
// volumetric overlap with the finger it rides on -- not just a coincident
// face at z = wall / x = face_x. OpenSCAD explicitly warns that unions of
// exactly-touching faces can render non-manifold or as separate shells.
// bond_eps sets how far each feature is extended into its parent solid; it
// is well within finger_w (1.0 mm) and does not change any externally
// visible dimension (hook_height, ridge_reach, eff_l, etc.).
bond_eps = 0.6;
// Tab-side undercut sizing (see latch_tab()): removes delta_pass minus the
// small residual settle_interference retained for tactile retention, over
// the ridge's own z-band (plus a manufacturing margin).
settle_interference = 0.05;
undercut_margin = 0.2;
// Upper-receiver capturing geometry: a back wall and roof beyond the hook's
// nominal footprint so the installed lip is captured, not just clearance-fit.
receiver_back = 1.5;
receiver_roof = 1.5;

part = "grid"; // grid, carrier, flex_clip, spring_clip, coupon, panel

module rounded_box(size, radius = 1.5) {
    translate([radius, radius, radius]) {
        minkowski() {
            cube([size[0] - 2 * radius, size[1] - 2 * radius, size[2] - 2 * radius]);
            sphere(radius);
        }
    }
}

module grid_section() {
    // The inspection hole is cut in three bands rather than one, leaving solid
    // full-width bridges under the latch rail and each upper-receiver housing so
    // those features bond into the perimeter frame instead of floating over the
    // open center.
    band_bottom_y0 = latch_rail_y0 - 2;
    band_bottom_y1 = latch_rail_y0 + latch_rail_depth + 2;
    band_top_y0 = interface_y - 2;
    band_top_y1 = interface_y + hook_depth + receiver_back + 2;
    difference() {
        cube([pitch_w, pitch_h, wall]);
        // Keep the center open so the wall surface can be inspected and dried.
        translate([rib, rib, -0.1])
            cube([pitch_w - 2 * rib, band_bottom_y0 - rib, wall + 0.2]);
        translate([rib, band_bottom_y1, -0.1])
            cube([pitch_w - 2 * rib, band_top_y0 - band_bottom_y1, wall + 0.2]);
        translate([rib, band_top_y1, -0.1])
            cube([pitch_w - 2 * rib, pitch_h - rib - band_top_y1, wall + 0.2]);
        // Top edge receives the matching key from the section above.
            translate([pitch_w / 2 - 3 - registration_clearance,
                       pitch_h - 2 - registration_clearance, -0.1])
                cube([6 + 2 * registration_clearance,
                      4 + 2 * registration_clearance, wall + 0.2]);
    }
    // Perimeter ribs define the visible grout field.
    translate([0, 0, wall]) cube([pitch_w, rib, wall]);
    translate([0, pitch_h - rib, wall]) cube([pitch_w, rib, wall]);
    translate([0, rib, wall]) cube([rib, pitch_h - 2 * rib, wall]);
    translate([pitch_w - rib, rib, wall]) cube([rib, pitch_h - 2 * rib, wall]);
    // Upper hook receptacles and lower latch rails.
    for (x = [rib + 16, pitch_w - rib - 16])
        upper_receiver(x);
    latch_rail();
    // Bottom key mates with the receiving slot in the next section.
    translate([pitch_w / 2 - 3 + registration_clearance,
               -2 + registration_clearance, 0])
        cube([6 - 2 * registration_clearance,
              4 - 2 * registration_clearance, wall]);
}

module latch_rail() {
    // Two rail stubs flank the (now rigid) tab notch, but only one carries a
    // rounded retention ridge (tapered top and bottom via hull()) that
    // intrudes into the notch over a limited z-band; the other stub presents
    // a plain, clearance-only face. Only the left stub carries a retention
    // ridge. With ridges on both sides, the throat between them (18.7 mm) was
    // narrower than the rigid foot (19.3 mm), so no lateral shift could clear
    // both at once. A single ridge lets clearance be taken up entirely toward
    // the open (ridge-free) side.
    //
    // The ridge itself sits on a compliant spring finger, not on the rigid
    // stub body: a cantilever (see finger_w/finger_gap above), isolated from
    // the rest of the stub by a thin slot over its whole height and fixed
    // only where its base bonds into the solid grid floor below z = wall.
    // The strain-governing length is eff_l = ridge_z0 + ridge_h / 2 = 3.5 mm
    // (the height of the ridge's point of maximum reach, not the finger's
    // free tip -- see the calculation above finger_w). The finger deflects
    // out of the way on insertion/removal within that documented strain
    // target and, thanks to the tab-side undercut (see latch_tab()), is left
    // only lightly loaded rather than held open once settled.
    face_x = latch_tab_x0 - clearance;
    finger_x0 = face_x - finger_w;
    difference() {
        // The rail's base solid extends bond_eps below z = wall so it has
        // real volumetric overlap with the grid floor slab rather than a
        // coincident face; every cut below still stops at z = wall, so this
        // extra depth stays solid and forms the finger's genuine fixed root.
        translate([latch_rail_x0, latch_rail_y0, wall - bond_eps])
            cube([latch_rail_x1 - latch_rail_x0, latch_rail_depth, hook_height + bond_eps]);
        translate([latch_tab_x0 - clearance, latch_rail_y0 - 0.1, wall - 0.1])
            cube([latch_tab_w + 2 * clearance, latch_rail_depth + 0.2, hook_height + 0.2]);
        // Isolation slot: frees the spring finger from the rest of the left
        // stub above z = wall, so only the bonded material below fixes it,
        // matching the cantilever model used in the strain check. Above the
        // root_fillet_r band the slot is a constant finger_gap width; within
        // that band its lower corner is rounded with an explicit, printable
        // radius (a quarter-cylinder cut from a corner box, not a hull
        // taper to a near-zero seam), so the root blends smoothly into the
        // floor with a finite radius and the section stays uniform
        // (finger_w) everywhere the beam calculation above applies.
        translate([finger_x0 - finger_gap, latch_rail_y0 - 0.1, wall + root_fillet_r])
            cube([finger_gap, latch_rail_depth + 0.2, hook_height + 0.2 - root_fillet_r]);
        translate([finger_x0 - finger_gap, latch_rail_y0 - 0.1, wall])
            cube([finger_gap - root_fillet_r, latch_rail_depth + 0.2, root_fillet_r]);
        intersection() {
            translate([finger_x0 - root_fillet_r, latch_rail_y0 - 0.1, wall])
                cube([root_fillet_r, latch_rail_depth + 0.2, root_fillet_r]);
            translate([finger_x0 - root_fillet_r, latch_rail_y0 - 0.1, wall + root_fillet_r])
                rotate([-90, 0, 0])
                    cylinder(r = root_fillet_r, h = latch_rail_depth + 0.2, $fn = 32);
        }
    }
    // The ridge's root cross-section is embedded bond_eps into the finger
    // (rather than starting exactly at its face) so it has real volumetric
    // overlap with the finger, not a coincident face at x = face_x. This
    // only moves material backward into the finger's own solid interior
    // (bond_eps = 0.6 mm is well within finger_w = 1.0 mm); ridge_reach,
    // measured from face_x, and therefore eff_l and the strain calculation
    // above are unaffected.
    translate([face_x, latch_rail_y0 + 0.2, wall])
        hull() {
            translate([-bond_eps, 0, ridge_z0])
                cube([0.01 + bond_eps, latch_rail_depth - 0.4, 0.01]);
            translate([ridge_reach, 0, ridge_z0 + ridge_h / 2])
                cube([0.01, latch_rail_depth - 0.4, 0.01]);
            translate([-bond_eps, 0, ridge_z0 + ridge_h])
                cube([0.01 + bond_eps, latch_rail_depth - 0.4, 0.01]);
        }
}

module upper_receiver(x) {
    // Side walls flank the mating slot; the hook (see upper_hook) is inset by
    // `clearance` from this same nominal footprint on X and Z. The housing also
    // extends past the hook's nominal depth (Y) and height (Z) to leave a solid
    // back wall and roof: capturing geometry so the installed lip cannot pull
    // straight out along Y or Z. The front (toward the carrier body) stays open
    // so the hook keeps a solid root bridging into the carrier shell.
    housing_wall = 1.5;
    difference() {
        translate([x - hook_depth / 2 - housing_wall, interface_y, wall])
            cube([hook_depth + 2 * housing_wall,
                  hook_depth + receiver_back,
                  hook_env_h + receiver_roof]);
        // Cavity: the hook's nominal footprint plus installation clearance on X
        // and Z (sized to the hook's full envelope height, including its lip
        // rise) and an open front face, stopping short of the back wall and roof
        // so both remain solid and capture the hook's lip once installed.
        translate([x - hook_depth / 2 - clearance, interface_y - 0.1, wall - 0.1])
            cube([hook_depth + 2 * clearance, hook_depth + clearance, hook_env_h + clearance]);
    }
}

module upper_hook(x) {
    hook_w = hook_depth - 2 * clearance;
    hook_d = hook_depth - 2;
    hook_top = hook_height - 1;
    lip_rise = 1.0;
    translate([x, hook_local_y, 1]) {
        cube([hook_w, hook_d, hook_top]);
        // Lead-in chamfer built with hull() so it stays fully within the tongue's
        // own X/Y footprint; it only rises above the tongue's own top face and so
        // cannot reach the receiver's floor or back wall once installed.
        hull() {
            translate([0, hook_d - 2, hook_top - 0.1])
                cube([hook_w, 2, 0.1]);
            translate([0, hook_d - 2, hook_top])
                cube([hook_w, 0.1, lip_rise]);
        }
    }
}

module carrier_shell() {
    difference() {
        rounded_box([tile_w, tile_h, 5], 1.5);
        translate([3, 3, 2]) cube([tile_w - 6, tile_h - 6, 4]);
        // Concealed lower finger recess; the release path remains inspectable.
        translate([tile_w / 2 - release_depth / 2, -0.1, 0])
            cube([release_depth, 6, 3]);
    }
}

module carrier() {
    housing_wall = 1.5;
    // Rail-stub X ranges (left/right of the tab notch); the stub reliefs
    // below clear only these ranges. The tab itself is rigid and stays fully
    // bonded to the carrier floor (compliance lives in the rail's spring
    // finger instead -- see latch_rail()), so no separate notch relief is cut.
    stub1_x0 = latch_rail_x0;
    stub1_x1 = latch_tab_x0 - clearance;
    stub2_x0 = latch_tab_x0 + latch_tab_w + clearance;
    stub2_x1 = latch_rail_x1;
    translate([rib, rib, mount_z]) {
        difference() {
            carrier_shell();
            // Relief for each rigid rail stub (plus clearance) so the carrier's
            // flat floor never touches them; the tab region between the stubs
            // stays unrelieved so it bonds fully into the carrier floor (it is
            // rigid -- no neck to free for flexing).
            translate([stub1_x0 - rib - clearance, latch_rail_y0 - rib - clearance, -0.1])
                cube([stub1_x1 - stub1_x0 + 2 * clearance,
                      latch_rail_depth + 2 * clearance,
                      hook_height + clearance + 0.1]);
            translate([stub2_x0 - rib - clearance, latch_rail_y0 - rib - clearance, -0.1])
                cube([stub2_x1 - stub2_x0 + 2 * clearance,
                      latch_rail_depth + 2 * clearance,
                      hook_height + clearance + 0.1]);
            // Relief frame (C-shaped, open on the near/front side) around each
            // receiver housing: clears the housing's side walls, back wall, and
            // roof (plus clearance), but leaves the hook's own footprint solid and
            // leaves the front (toward the carrier's body) completely unrelieved
            // so the floor forms a continuous bridge from the shell into the
            // hook's root -- the ring never fully encircles the hook footprint,
            // so it can't isolate it from the rest of the shell.
            for (x = [rib + 16, pitch_w - rib - 16])
                difference() {
                    translate([x - hook_depth / 2 - housing_wall - clearance - rib,
                               interface_y - rib,
                               -0.1])
                        cube([hook_depth + 2 * housing_wall + 2 * clearance,
                              hook_depth + receiver_back + clearance,
                              hook_env_h + receiver_roof + clearance + 0.1]);
                    translate([x - hook_depth / 2 - rib - 0.05,
                               interface_y - rib - 0.05,
                               -0.2])
                        cube([hook_depth + 0.1,
                              hook_depth + 0.1,
                              hook_env_h + receiver_roof + clearance + 0.6]);
                }
        }
        // Each hook's own footprint was left untouched by the relief frame above,
        // so it remains solid, continuous carrier-floor material: a bonded root
        // for the hook rather than a disconnected block floating in a pocket.
        upper_hook(hook_local_x_left);
        upper_hook(hook_local_x_right);
        latch_tab();
    }
}

module latch_tab() {
    // Rigid engaging tab: a single solid, full-height, full-nominal-width
    // block bonded directly into the carrier's floor. The compliance needed
    // to clear the rail's retention ridge lives in the rail's spring finger
    // (see latch_rail()), so the tab itself carries load through durable,
    // unflexed geometry rather than acting as its own flexure.
    foot_x0 = latch_tab_x0 + clearance - rib;
    foot_w = latch_tab_w - 2 * clearance;
    tab_y0 = latch_rail_y0 + clearance - rib;
    tab_yw = latch_rail_depth - 2 * clearance;
    // Settled-position undercut: because the tab's z-span exactly covers the
    // notch height, a plain rigid block would keep the ridge's whole z-band
    // permanently occupied once seated, so the finger could never relax
    // (the flaw the previous round left unfixed). This recess, cut into the
    // tab's ridge-facing shoulder over the ridge's own z-band (plus
    // undercut_margin), leaves only settle_interference of residual overlap
    // in the settled position, letting the finger spring back close to
    // neutral instead of staying held open. undercut_depth removes the rest
    // of the insertion/removal interference (delta_pass, see the calculation
    // above finger_w).
    delta_pass = ridge_reach - 2 * clearance;
    undercut_depth = delta_pass - settle_interference;
    difference() {
        translate([foot_x0, tab_y0, 0])
            cube([foot_w, tab_yw, hook_height]);
        translate([foot_x0 - 0.1, tab_y0 - 0.1, ridge_z0 - undercut_margin])
            cube([undercut_depth + 0.1, tab_yw + 0.2, ridge_h + 2 * undercut_margin]);
    }
}

module flex_clip() {
    // Integral flexure comparison coupon; roots are rounded to reduce cracking.
    difference() {
        rounded_box([20, 18, 4], 1.5);
        translate([4, 5, -0.1]) cube([12, 10, 4.2]);
    }
    translate([8, 12, 4]) cube([4, 6, 5]);
}

module spring_clip() {
    // Replaceable service clip with a positive rail and finger release.
    difference() {
        rounded_box([24, 18, 4], 1.5);
        translate([4, 4, -0.1]) cube([16, 10, 4.2]);
    }
    translate([9, 12, 4]) cube([6, 7, 4]);
    translate([7, 16, 4]) cube([10, 3, 3]);
}

module coupon() {
    // Three mating-interface variants are laid out for one print and one measurement pass.
    for (i = [0:2]) {
        c = 0.20 + i * 0.15;
        translate([i * 32, 0, 0]) {
            cube([28, 30, 4]);
            // Paired clearance bars provide a repeatable dimensional coupon.
            translate([4, 4, 4]) cube([20, 4, 4]);
            translate([4, 8 + c, 4]) cube([20, 4, 4]);
            translate([4, 18, 4]) cube([20, 4, 4]);
            translate([4, 22 + c, 4]) cube([20, 4, 4]);
        }
    }
}

module panel() {
    for (col = [0:2])
        for (row = [0:2])
            translate([col * pitch_w, row * pitch_h, 0])
                grid_section();
}

if (part == "grid") grid_section();
if (part == "carrier") carrier();
if (part == "flex_clip") flex_clip();
if (part == "spring_clip") spring_clip();
if (part == "coupon") coupon();
if (part == "panel") panel();
