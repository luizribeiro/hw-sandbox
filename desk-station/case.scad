/**
 * All dimensions on this file are in mm.
 */

// Case settings
CASE_ANGLE = 30.0;
CASE_CORNER_RADIUS = 10.0;
CASE_DEPTH = 60.0;
CASE_HEIGHT = 50.0;
CASE_SHELL_WIDTH = 5.0;
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

module case_side_polygon(depth, height, angle) {
  polygon(points=[
    [0, 0],
    [depth, 0],
    [depth, height],
    [depth * tan(angle), height],
  ]);
}

module solid_case(
  corner_radius,
  height,
  depth,
  angle,
  width,
) {
  rotate([90, 0, 90]) minkowski() {
    sphere(r=corner_radius);
    linear_extrude(height=width)
      case_side_polygon(depth, height, angle);
  }
}

module case_shell(
  corner_radius,
  height,
  depth,
  angle,
  width,
  shell_width,
) {
  difference() {
    solid_case(
      corner_radius=corner_radius,
      height=height,
      depth=depth,
      angle=angle,
      width=width
    );
    translate([shell_width / 2, shell_width / 2, shell_width / 2])
      scale([
        1 - shell_width / (corner_radius * 2 + width),
        1 - shell_width / (corner_radius * 2 + depth),
        1 - shell_width / (corner_radius * 2 + height),
      ])
      solid_case(
        corner_radius=corner_radius,
        height=height,
        depth=depth,
        angle=angle,
        width=width
      );
    translate([-CASE_CORNER_RADIUS * 2, 0, 0])
      rotate([90, 0, 90])
      linear_extrude(height=(CASE_WIDTH + CASE_CORNER_RADIUS * 4))
        side_holes_polygon();
  }
}

module side_holes_polygon() {
  intersection() {
    step = SIDE_HOLE_RADIUS / SIDE_HOLE_DENSITY;
    case_side_polygon(CASE_DEPTH, CASE_HEIGHT, CASE_ANGLE);
    for (x = [-step : step : CASE_DEPTH + step])
      for (y = [((x / step) % 2) * SIDE_HOLE_RADIUS - step: step : CASE_HEIGHT + step])
        translate([x, y]) circle(r=SIDE_HOLE_RADIUS);
  }
}

case_shell(
  CASE_CORNER_RADIUS,
  CASE_HEIGHT,
  CASE_DEPTH,
  CASE_ANGLE,
  CASE_WIDTH,
  CASE_SHELL_WIDTH
);
