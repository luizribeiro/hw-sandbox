/**
 * All dimensions on this file are in mm.
 */

$fn = 100;

module snapping_pin(
  board_thickness = 2.0,
  hole_diameter = 1.9,
  snap_cone_diameter = 3,
  snap_cone_height = 4,
  snap_cone_gap_width = 1,
  snap_cone_gap_height = 5,
) {
  difference() {
    union() {
      cylinder(h=board_thickness, r=hole_diameter / 2);
      translate([0, 0, board_thickness])
        cylinder(h=snap_cone_height, r1=snap_cone_diameter / 2, r2=0);
    }

    translate([
      -snap_cone_gap_width/2,
      -snap_cone_diameter/2,
      board_thickness + snap_cone_height - snap_cone_gap_height,
    ])
      cube([snap_cone_gap_width, snap_cone_diameter, snap_cone_gap_height]);
  }
}

snapping_pin();
