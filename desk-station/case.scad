/**
 * All dimensions on this file are in mm.
 */

// Case settings
CASE_ANGLE = 30.0;
CASE_CORNER_RADIUS = 10.0;
CASE_DEPTH = 60.0;
CASE_HEIGHT = 50.0;
CASE_THICKNESS = 5.0;
CASE_WIDTH = 90.0;
SIDE_HOLE_RADIUS = 2.5;
SIDE_HOLE_DENSITY = 0.35;

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

module case_side_polygon() {
  polygon(points=[
    [0, 0],
    [CASE_DEPTH, 0],
    [CASE_DEPTH, CASE_HEIGHT],
    [CASE_DEPTH * tan(CASE_ANGLE), CASE_HEIGHT],
  ]);
}

module solid_case() {
  rotate([90, 0, 90]) minkowski() {
    sphere(r=CASE_CORNER_RADIUS);
    linear_extrude(height=CASE_WIDTH)
      case_side_polygon();
  }
}

module case_shell() {
  difference() {
    solid_case();
    translate([CASE_THICKNESS / 2, CASE_THICKNESS / 2, CASE_THICKNESS / 2])
      scale([
        1 - CASE_THICKNESS / (CASE_CORNER_RADIUS * 2 + CASE_WIDTH),
        1 - CASE_THICKNESS / (CASE_CORNER_RADIUS * 2 + CASE_DEPTH),
        1 - CASE_THICKNESS / (CASE_CORNER_RADIUS * 2 + CASE_HEIGHT),
      ])
      solid_case();
    translate([-CASE_CORNER_RADIUS * 2, 0, 0])
      rotate([90, 0, 90])
      linear_extrude(height=(CASE_WIDTH + CASE_CORNER_RADIUS * 4))
        side_holes_polygon();
  }
}

module side_holes_polygon() {
  intersection() {
    step = SIDE_HOLE_RADIUS / SIDE_HOLE_DENSITY;
    case_side_polygon();
    for (x = [-step : step : CASE_DEPTH + step])
      for (y = [((x / step) % 2) * SIDE_HOLE_RADIUS - step: step : CASE_HEIGHT + step])
        translate([x, y]) circle(r=SIDE_HOLE_RADIUS);
  }
}

case_shell();
