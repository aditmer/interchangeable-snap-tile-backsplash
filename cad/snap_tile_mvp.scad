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
interface_y = pitch_h - rib - hook_depth;
hook_local_y = interface_y - rib + clearance;
hook_local_x_left = 16 - hook_depth / 2 + clearance;
hook_local_x_right = tile_w - 12 - hook_depth + clearance;

part = "grid"; // grid, carrier, flex_clip, spring_clip, coupon, panel
clearance = 0.35;

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
    translate([rib + 10, clip_datum, wall])
        cube([pitch_w - 2 * rib - 20, 3, hook_height]);
    // Bottom key mates with the receiving slot in the next section.
    translate([pitch_w / 2 - 3 + registration_clearance,
               -2 + registration_clearance, 0])
        cube([6 - 2 * registration_clearance,
              4 - 2 * registration_clearance, wall]);
}

module upper_receiver(x) {
    // A pocket with a retaining ledge gives the hook a defined insertion path.
    difference() {
        translate([x - hook_depth / 2, interface_y, wall])
            cube([hook_depth, hook_depth, hook_height]);
        translate([x - hook_depth / 2 + clearance,
                   interface_y + clearance,
                   wall + 1])
            cube([hook_depth - 2 * clearance,
                  hook_depth - 2,
                  hook_height]);
    }
}

module upper_hook(x) {
    translate([x, hook_local_y, 1])
        cube([hook_depth - 2 * clearance, hook_depth - 2, hook_height - 1]);
    // The short angled lip provides the documented lead-in.
    translate([x, tile_h - 2, 0])
        rotate([30, 0, 0])
            cube([hook_depth - 2 * clearance, 2, hook_height + 1]);
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
    translate([rib, rib, mount_z]) {
        carrier_shell();
        upper_hook(hook_local_x_left);
        upper_hook(hook_local_x_right);
        translate([tile_w / 2 - 10, clip_datum, -1])
            cube([20, 4, hook_height + 1]);
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
