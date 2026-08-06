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
    difference() {
        cube([pitch_w, pitch_h, wall]);
        // Keep the center open so the wall surface can be inspected and dried.
        translate([rib, rib, -0.1])
            cube([pitch_w - 2 * rib, pitch_h - 2 * rib, wall + 0.2]);
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
    difference() {
        translate([latch_rail_x0, latch_rail_y0, wall])
            cube([latch_rail_x1 - latch_rail_x0, latch_rail_depth, hook_height]);
        // Clears the carrier's flexing latch tab (plus clearance on every side) so
        // the rigid rail can never touch the tab once the carrier is seated.
        translate([latch_tab_x0 - clearance, latch_rail_y0 - 0.1, wall - 0.1])
            cube([latch_tab_w + 2 * clearance, latch_rail_depth + 0.2, hook_height + 0.2]);
    }
    // Bottom key mates with the receiving slot in the next section.
    translate([pitch_w / 2 - 3 + registration_clearance,
               -2 + registration_clearance, 0])
        cube([6 - 2 * registration_clearance,
              4 - 2 * registration_clearance, wall]);
}

module upper_receiver(x) {
    // Side walls flank the mating slot; the hook (see upper_hook) is inset by
    // `clearance` from this same nominal footprint on X, Y, and Z, so sizing the
    // cavity to the full nominal footprint gives real clearance on every axis
    // instead of coincidentally matching the hook's bounds.
    housing_wall = 1.5;
    difference() {
        translate([x - hook_depth / 2 - housing_wall, interface_y, wall])
            cube([hook_depth + 2 * housing_wall, hook_depth, hook_height]);
        // Cavity: the hook's full nominal footprint, left open top and bottom so
        // the lead-in lip has clear travel and never bottoms out on a floor or
        // back wall.
        translate([x - hook_depth / 2, interface_y, wall - 0.1])
            cube([hook_depth, hook_depth, hook_height + 3]);
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
    translate([rib, rib, mount_z]) {
        difference() {
            carrier_shell();
            // Relief channel over the full latch-rail footprint (plus clearance)
            // so the carrier's flat floor never touches the rigid rail stubs on
            // either side of the flex tab added below.
            translate([latch_rail_x0 - rib - clearance,
                       latch_rail_y0 - rib - clearance,
                       -0.1])
                cube([latch_rail_x1 - latch_rail_x0 + 2 * clearance,
                      latch_rail_depth + 2 * clearance,
                      hook_height + clearance + 0.1]);
            // Relief pockets over each upper-receiver housing (plus clearance) so
            // the carrier's flat floor never touches the housing walls that
            // surround the hooks added below.
            for (x = [rib + 16, pitch_w - rib - 16])
                translate([x - hook_depth / 2 - housing_wall - clearance - rib,
                           interface_y - clearance - rib,
                           -0.1])
                    cube([hook_depth + 2 * housing_wall + 2 * clearance,
                          hook_depth + 2 * clearance,
                          hook_height + clearance + 0.1]);
        }
        upper_hook(hook_local_x_left);
        upper_hook(hook_local_x_right);
        // Flexing latch tab: sized clearance-smaller than the rail notch on X and
        // Y so it seats inside the gap between the rail stubs without touching
        // the rigid rail (see grid_section's latch-rail difference()).
        translate([latch_tab_x0 + clearance - rib, latch_rail_y0 + clearance - rib, 0])
            cube([latch_tab_w - 2 * clearance, latch_rail_depth - 2 * clearance, hook_height]);
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
