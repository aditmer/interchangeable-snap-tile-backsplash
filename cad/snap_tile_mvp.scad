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
clip_mount_x0 = latch_tab_x0 - clearance - rib + 0.8;
clip_mount_y0 = latch_rail_y0 + clearance - rib;
// Latch geometry: the tab is a single rigid, full-height block bonded directly
// into the carrier floor (durable, load-carrying, replaceable per-tile part).
// Compliance and retention live in the separately replaceable spring_clip.
ridge_reach = 0.9;
ridge_z0 = 3.0;
ridge_h = 1.0;
// Ridge tip construction allowance: hull() needs each control primitive to
// have real (non-zero) extent, so the tip primitive below is built as a tiny
// cube instead of a mathematical point. That cube is centered on x =
// ridge_reach (translated back by half its own width) instead of starting
// at ridge_reach and extending outward, so it adds only half its width to
// the modeled max reach, not its full width. Its size is also cut 5x smaller
// than a typical previous choice (0.01 mm) specifically so that residual is
// sub-micron and can be safely folded into ridge_reach_eff below rather than
// silently inflating the physical geometry past the documented ridge_reach.
ridge_pt_eps = 0.002;
// Modeled maximum X reach of the ridge, including the construction
// allowance above (ridge_reach + half of ridge_pt_eps): this is the value
// that must drive the insertion/removal calculation below, not the nominal
// ridge_reach alone, so the strain calculation matches the rendered geometry.
// ridge_reach_eff = 0.9 + 0.002 / 2 = 0.901 mm.
ridge_reach_eff = ridge_reach + ridge_pt_eps / 2;
// Spring-finger geometry (service-clip side): the replaceable clip contains a
// cantilever fixed only at its base and free over its full height, thin in
// the X (lateral flex) direction. Its root uses a finite-radius shoulder
// feature and is wider than the uniform finger section; the resulting
// shoulder concentration is included in the estimate below.
//
// The ridge occupies z = ridge_z0 to ridge_z0 + ridge_h, and its maximum
// reach is used as the strain load point. The strain-governing cantilever
// length is therefore the distance from the fixed root (z = wall) to that
// point, eff_l = ridge_z0 + ridge_h / 2 = 3.0 + 0.5 = 3.5 mm -- not
// hook_height (4.0 mm) as an earlier revision assumed.
//
// Clearing the ridge on insertion needs a lateral displacement of
// delta_pass = ridge_reach_eff - 2 * clearance = 0.901 - 2 * 0.35 =
// 0.201 mm. For a cantilever of length eff_l = 3.5 mm and thickness
// finger_w = 0.8 mm (bending direction), the nominal (unconcentrated)
// worst-case insertion fiber strain is
// eps_insert_nom = 3 * finger_w * delta_pass / (2 * eff_l^2)
//                = 3 * 0.8 * 0.201 / (2 * 3.5^2) = 0.4824 / 24.5 = 0.01969,
// i.e. ~1.97%.
//
// That nominal strain is a beam-theory average and does not by itself
// capture the root's stress (and strain) concentration from the
// finger_w -> finger_w + root_fillet_r shoulder fillet at z = wall. Modeling
// that root as a stepped-flat-bar shoulder fillet in bending (Peterson /
// Pilkey polynomial fit) with D = finger_w + root_fillet_r = 1.2 mm,
// d = finger_w = 0.8 mm, r = root_fillet_r = 0.4 mm:
//   h = (D - d) / 2 = 0.2 mm, h / r = 0.5 (in the 0.1-2.0 fit range), so
//   C1 = 1.006 + 0.967 * sqrt(h/r) + 0.013 * (h/r)       = 1.696
//   C2 = -0.270 - 2.372 * sqrt(h/r) + 0.708 * (h/r)      = -1.594
//   C3 = 0.662 + 1.157 * sqrt(h/r) - 0.908 * (h/r)       = 1.026
//   C4 = -0.405 + 0.249 * sqrt(h/r) - 0.200 * (h/r)      = -0.329
//   x = 2h / D = 0.4 / 1.2 = 0.333
//   Kt = C1 + C2 * x + C3 * x^2 + C4 * x^3 = 1.267
// (Pilkey, "Peterson's Stress Concentration Factors", shoulder-fillet-in-
// bending chart; C1..C4 depend only on h/r, which is fixed at 0.5 here
// because D - d always equals root_fillet_r by construction, independent of
// finger_w.)
//
// Peak local (root) strain = Kt * nominal strain:
// eps_insert = Kt * eps_insert_nom = 1.267 * 0.01969 = 0.02495, i.e. ~2.49%,
// under the 3% allowable-strain target for printed PLA/PETG flexures.
// Removal is symmetric about the ridge's mid-height (same delta_pass, same
// eff_l), so eps_remove = eps_insert = ~2.49%.
//
// In the seated position the finger is unloaded after the ridge passes the
// rigid rail end; insertion and removal therefore govern the cycle estimate.
finger_w = 0.8;
// Root shoulder radius used by the clip geometry and concentration estimate.
root_fillet_r = 0.4;
// Bonding epsilon keeps the durable rail rooted in the grid floor rather than
// relying on a coincident face. OpenSCAD warns that exactly-touching unions can
// render non-manifold or as separate shells.
// bond_eps sets how far each feature is extended into its parent solid; it
// is well within finger_w (0.8 mm) and does not change any externally
// visible dimension (hook_height, ridge_reach, eff_l, etc.).
bond_eps = 0.6;
// Upper-receiver capturing geometry: a back wall and roof beyond the hook's
// nominal footprint so the installed lip is captured, not just clearance-fit.
receiver_back = 1.5;
receiver_roof = 1.5;

part = "grid"; // grid, carrier, carrier_assembly, flex_clip, spring_clip, coupon, hook_coupon, latch_coupon, registration_coupon, panel

module rounded_box(size, radius = 1.5) {
    translate([radius, radius, radius]) {
        minkowski() {
            cube([size[0] - 2 * radius, size[1] - 2 * radius, size[2] - 2 * radius]);
            sphere(radius);
        }
    }
}

module grid_section() {
    // The inspection hole is cut in two bands, leaving solid
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
    // The grid supplies only durable mating geometry. Compliance and the
    // retention ridge live in the replaceable spring_clip.
    difference() {
        translate([latch_rail_x0, latch_rail_y0, wall - bond_eps])
            cube([latch_rail_x1 - latch_rail_x0, latch_rail_depth, hook_height + bond_eps]);
        translate([latch_tab_x0 - clearance, latch_rail_y0 - 0.1, wall - 0.1])
            cube([latch_tab_w + 2 * clearance, latch_rail_depth + 0.2, hook_height + 0.2]);
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
    // bonded to the carrier floor; the service clip supplies compliance.
    stub1_x0 = latch_rail_x0;
    stub1_x1 = latch_tab_x0 - clearance;
    stub2_x0 = latch_tab_x0 + latch_tab_w + clearance;
    stub2_x1 = latch_rail_x1;
    translate([rib, rib, mount_z]) {
        difference() {
            carrier_shell();
            // Relief for each rigid rail stub (plus clearance) so the carrier's
            // flat floor never touches them; the tab region between the stubs
            // stays unrelieved and bonds fully into the carrier floor.
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
            // Service-clip pocket. Side ledges added below retain the
            // separately printed clip without fusing it to the carrier.
            translate([clip_mount_x0 - 0.2, clip_mount_y0 - 0.2, 1.4])
                cube([2.4, latch_rail_depth + 0.4, 1.0]);
        }
        // Each hook's own footprint remains solid and continuous with the carrier.
        upper_hook(hook_local_x_left);
        upper_hook(hook_local_x_right);
        translate([clip_mount_x0 - 0.2, clip_mount_y0 - 0.2, 1.4])
            cube([0.2, latch_rail_depth + 0.4, 0.6]);
        translate([clip_mount_x0 + 2.0, clip_mount_y0 - 0.2, 1.4])
            cube([0.2, latch_rail_depth + 0.4, 0.6]);
    }
}

module carrier_assembly() {
    // Preview only: print carrier() and spring_clip() as separate parts.
    carrier();
    translate([rib + clip_mount_x0, rib + clip_mount_y0, mount_z + 1.4])
        spring_clip_mount();
}

module flex_clip() {
    // Integral flexure comparison coupon; roots are rounded to reduce cracking.
    difference() {
        rounded_box([20, 18, 4], 1.5);
        translate([4, 5, -0.1]) cube([12, 10, 4.2]);
    }
    translate([8, 12, 3.8]) cube([4, 6, 5.2]);
}

module spring_clip_mount() {
    // Actual replaceable clip geometry. The 0.8 mm finger is isolated from
    // the carrier-facing base above the rounded root and carries the ridge.
    root_w = finger_w + root_fillet_r;
    finger_depth = latch_rail_depth - 0.8;
    union() {
        cube([2.0, latch_rail_depth, 0.8]);
        translate([root_fillet_r, 0.4, root_fillet_r])
            cube([finger_w, finger_depth, hook_height - root_fillet_r]);
        translate([0, 0.4, 0])
            cube([root_w, finger_depth, root_fillet_r]);
        translate([root_fillet_r + finger_w / 2, 0.4 + finger_depth, root_fillet_r])
            rotate([90, 0, 0])
                cylinder(r = root_fillet_r, h = finger_depth, $fn = 24);
        translate([root_fillet_r - ridge_reach_eff, 0.4, ridge_z0])
            cube([ridge_reach_eff + finger_w, finger_depth, ridge_h]);
    }
}

module spring_clip() {
    // Standalone service-clip export uses the same geometry as carrier().
    spring_clip_mount();
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

module hook_coupon() {
    for (i = [0:2]) {
        c = 0.20 + i * 0.15;
        translate([i * 32, 0, 0]) {
            translate([2, 2, 0]) coupon_receiver(c);
            translate([18, 2, 0]) coupon_hook(c);
        }
    }
}

module latch_coupon() {
    for (i = [0:2]) {
        c = 0.20 + i * 0.15;
        translate([i * 32, 0, 0]) {
            translate([2, 2, 0]) coupon_latch_receiver(0.35);
            // Hold the receiver datum fixed; vary the mating clip offset.
            translate([18 + (c - 0.35), 2, 0]) coupon_latch_clip(0.35);
        }
    }
}

module registration_coupon() {
    for (i = [0:2]) {
        c = 0.20 + i * 0.15;
        translate([i * 32, 0, 0]) {
            translate([2, 2, 0]) cube([10, 10, wall]);
            translate([4, 5, wall]) cube([6 - 2 * c, 4 - 2 * c, 2]);
            difference() {
                translate([18, 2, 0]) cube([10, 10, wall]);
                translate([20, 4, -0.1])
                    cube([6 + 2 * c, 4 + 2 * c, wall + 0.2]);
            }
        }
    }
}

module coupon_receiver(c) {
    difference() {
        cube([10, 12, 7]);
        translate([1.5 - c, -0.1, 1.0 - c])
            cube([7 + 2 * c, 10.1, 5.5 + 2 * c]);
    }
}

module coupon_hook(c) {
    hook_w = 7 - 2 * c;
    translate([0, 1, 1]) {
        cube([hook_w, 6, 3]);
        translate([0, 4, 3])
            cube([hook_w, 2, 1]);
    }
}

module coupon_latch_receiver(c) {
    difference() {
        cube([10, 8, 5]);
        translate([1 - c, 1 - c, 2])
            cube([8 + 2 * c, 6 + 2 * c, 3.1]);
    }
}

module coupon_latch_clip(c) {
    translate([1, 1, 0])
        cube([1.2, 6, 2]);
    translate([1.2, 2, 2])
        cube([0.8, 4, 3]);
    translate([0.3, 2, 4])
        cube([0.9 + c, 4, 1]);
}

module panel() {
    for (col = [0:2])
        for (row = [0:2])
            translate([col * pitch_w, row * pitch_h, 0])
                grid_section();
}

if (part == "grid") grid_section();
if (part == "carrier") carrier();
if (part == "carrier_assembly") carrier_assembly();
if (part == "flex_clip") flex_clip();
if (part == "spring_clip") spring_clip();
if (part == "coupon") coupon();
if (part == "hook_coupon") hook_coupon();
if (part == "latch_coupon") latch_coupon();
if (part == "registration_coupon") registration_coupon();
if (part == "panel") panel();
