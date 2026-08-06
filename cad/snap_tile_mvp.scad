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
// Flex-tab geometry: a rigid root bonds into the carrier floor, a reduced-width
// neck provides the compliance, and a full-width foot presents an engaging face
// to a rounded retention ridge on each rail stub.
tab_root_h = 1.0;
tab_neck_h = 1.5;
tab_neck_w = 10;
ridge_reach = 1.0;
ridge_z0 = 3.0;
ridge_h = 1.0;
notch_flex_gap = 0.6;
fillet_h = 0.4;
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
    // Two rail stubs flank the flex-tab notch, but only one carries a rounded
    // retention ridge (tapered top and bottom via hull()) that intrudes into
    // the notch over a limited z-band; the other stub presents a plain,
    // clearance-only face. The carrier's tab flexes sideways, away from the
    // single ridge, to pass it, then springs back to engage it -- giving real
    // retention with a passable insertion/removal path for a single tab.
    difference() {
        translate([latch_rail_x0, latch_rail_y0, wall])
            cube([latch_rail_x1 - latch_rail_x0, latch_rail_depth, hook_height]);
        translate([latch_tab_x0 - clearance, latch_rail_y0 - 0.1, wall - 0.1])
            cube([latch_tab_w + 2 * clearance, latch_rail_depth + 0.2, hook_height + 0.2]);
    }
    // Only the left stub carries a retention ridge. With ridges on both sides,
    // the throat between them (18.7 mm) was narrower than the rigid foot
    // (19.3 mm), so no lateral shift of the single tab could clear both at
    // once. A single ridge lets the tab shift entirely toward the open
    // (ridge-free) side -- which keeps ample clearance throughout -- to pass
    // the one ridge on insertion/removal, then spring back to engage it.
    face_x = latch_tab_x0 - clearance;
    translate([face_x, latch_rail_y0 + 0.2, wall])
        hull() {
            translate([0, 0, ridge_z0])
                cube([0.01, latch_rail_depth - 0.4, 0.01]);
            translate([ridge_reach, 0, ridge_z0 + ridge_h / 2])
                cube([0.01, latch_rail_depth - 0.4, 0.01]);
            translate([0, 0, ridge_z0 + ridge_h])
                cube([0.01, latch_rail_depth - 0.4, 0.01]);
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
    // Rail-stub X ranges (left/right of the flex-tab notch); the stub reliefs
    // below clear only these ranges. The notch itself gets its own, separate
    // isolation relief further down, so the tab's root stays solid and bonds
    // into the carrier floor while the neck above it is free to flex.
    stub1_x0 = latch_rail_x0;
    stub1_x1 = latch_tab_x0 - clearance;
    stub2_x0 = latch_tab_x0 + latch_tab_w + clearance;
    stub2_x1 = latch_rail_x1;
    translate([rib, rib, mount_z]) {
        difference() {
            carrier_shell();
            // Relief for each rigid rail stub (plus clearance) so the carrier's
            // flat floor never touches them; the notch/tab region between the
            // stubs is relieved separately below (isolation relief), starting
            // above the tab's bonded root so the two reliefs don't overlap it.
            translate([stub1_x0 - rib - clearance, latch_rail_y0 - rib - clearance, -0.1])
                cube([stub1_x1 - stub1_x0 + 2 * clearance,
                      latch_rail_depth + 2 * clearance,
                      hook_height + clearance + 0.1]);
            translate([stub2_x0 - rib - clearance, latch_rail_y0 - rib - clearance, -0.1])
                cube([stub2_x1 - stub2_x0 + 2 * clearance,
                      latch_rail_depth + 2 * clearance,
                      hook_height + clearance + 0.1]);
            // Isolation relief for the flex-tab notch: carrier_shell() leaves a
            // solid floor from z 0..2, which used to fuse most of the tab's
            // z 1.0..2.5 neck into that floor (only 0.5 mm of the 1.5 mm neck
            // was free to flex). This clears the shell's floor material above
            // the tab's bonded root (z 0..tab_root_h) across the notch's full
            // width plus extra lateral room, so the whole neck -- and the
            // fillets above/below it -- can flex freely; only the root itself
            // stays fused to the carrier floor.
            translate([stub1_x1 - rib - notch_flex_gap,
                       latch_rail_y0 - rib - clearance,
                       tab_root_h])
                cube([stub2_x0 - stub1_x1 + 2 * notch_flex_gap,
                      latch_rail_depth + 2 * clearance,
                      5 - tab_root_h]);
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
    // Root: solid, full nominal width, bonded directly into the carrier's floor
    // (see carrier_shell -- floor spans z 0..2) so the tab is a continuous solid
    // with the shell instead of a disconnected block in the relief channel.
    // Above the root, carrier() now cuts an isolation relief through the whole
    // notch (see carrier()'s notch_flex_gap cut) so the neck and foot below are
    // truly free-standing -- only this root remains fused to the shell.
    foot_x0 = latch_tab_x0 + clearance - rib;
    foot_w = latch_tab_w - 2 * clearance;
    neck_x0 = latch_tab_x0 + (latch_tab_w - tab_neck_w) / 2 - rib;
    tab_y0 = latch_rail_y0 + clearance - rib;
    tab_yw = latch_rail_depth - 2 * clearance;
    translate([foot_x0, tab_y0, 0])
        cube([foot_w, tab_yw, tab_root_h]);
    // Root-to-neck fillet: a tapered hull (rather than an abrupt width step)
    // from the root's full width up to the neck's reduced width, reducing the
    // stress concentration at the base of the flexure.
    translate([0, tab_y0, 0])
        hull() {
            translate([foot_x0, 0, tab_root_h - 0.01])
                cube([foot_w, tab_yw, 0.01]);
            translate([neck_x0, 0, tab_root_h + fillet_h])
                cube([tab_neck_w, tab_yw, 0.01]);
        }
    // Neck: reduced-width compliant beam giving the foot room to flex sideways
    // past the rail's retention ridge on insertion and removal. This straight
    // section, plus the fillets on either side of it, spans the full nominal
    // neck band (z tab_root_h .. tab_root_h + tab_neck_h) and is now entirely
    // clear of the carrier's floor, free to flex.
    translate([neck_x0, tab_y0, tab_root_h + fillet_h])
        cube([tab_neck_w, tab_yw, tab_neck_h - 2 * fillet_h]);
    // Neck-to-foot fillet: mirrors the root-to-neck fillet, tapering back out
    // to the full engaging width.
    translate([0, tab_y0, 0])
        hull() {
            translate([neck_x0, 0, tab_root_h + tab_neck_h - fillet_h])
                cube([tab_neck_w, tab_yw, 0.01]);
            translate([foot_x0, 0, tab_root_h + tab_neck_h + 0.01])
                cube([foot_w, tab_yw, 0.01]);
        }
    // Foot: back to the tab's full nominal width so it presents an engaging face
    // to the rail's retention ridge (see latch_rail()); it intentionally overlaps
    // the ridge band by design, requiring the neck above to flex during seating.
    translate([foot_x0, tab_y0, tab_root_h + tab_neck_h])
        cube([foot_w, tab_yw, hook_height - tab_root_h - tab_neck_h]);
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
