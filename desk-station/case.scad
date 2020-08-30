/**
 * All dimensions on this file are in mm.
 */

// Case dimensions
CASE_DEPTH = 55.0;
CASE_HEIGHT = 60.0;
CASE_THICKNESS = 5.0;
CASE_WIDTH = 85.0;

// Case appearence
CASE_ANGLE = 75.0;
CASE_CORNER_RADIUS = 5.0;

// Side-hole settings
CASE_HAS_HOLES = true;
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
  standoff_height = 5,
  standoff_width = 3,
) {
  difference() {
    union() {
      cylinder(h=standoff_height, r=standoff_width / 2);
      translate([0, 0, standoff_height]) {
        cylinder(h=board_thickness, r=hole_diameter / 2);
        translate([0, 0, board_thickness])
          cylinder(h=snap_cone_height, r1=snap_cone_diameter / 2, r2=0);
      }
    }

    translate([
      -snap_cone_gap_width/2,
      -snap_cone_diameter/2,
      board_thickness + snap_cone_height + standoff_height - snap_cone_gap_height,
    ])
      cube([snap_cone_gap_width, snap_cone_diameter, snap_cone_gap_height]);
  }
}

module case_side_polygon() {
  polygon(points=[
    [0, 0],
    [CASE_DEPTH, 0],
    [CASE_DEPTH, CASE_HEIGHT],
    [CASE_HEIGHT / tan(CASE_ANGLE), CASE_HEIGHT],
  ]);
}

module solid_case() {
  rotate([90, 0, 90]) minkowski() {
    sphere(r=CASE_CORNER_RADIUS);
    linear_extrude(height=CASE_WIDTH)
      case_side_polygon();
  }
}

module display_hole() {
  rotate([CASE_ANGLE - 180, 0, 0])
    translate([
      0,
      -CASE_HEIGHT * sin(CASE_ANGLE),
      -CASE_CORNER_RADIUS + CASE_THICKNESS / 2
    ])
    translate([CASE_WIDTH - 80, 0, 0])
    translate([6, 6, -CASE_THICKNESS])
      cube([62.6, 29.6, CASE_THICKNESS]);
}

module back_hole() {
  translate([0, CASE_DEPTH, 0])
    cube([CASE_WIDTH, CASE_THICKNESS * 2, CASE_HEIGHT]);
}

module case_shell() {
  difference() {
    solid_case();
    scale([
      1 - CASE_THICKNESS / (CASE_CORNER_RADIUS * 2 + CASE_WIDTH),
      1 - CASE_THICKNESS / (CASE_CORNER_RADIUS * 2 + CASE_DEPTH),
      1 - CASE_THICKNESS / (CASE_CORNER_RADIUS * 2 + CASE_HEIGHT),
    ])
      translate([CASE_THICKNESS / 2, CASE_THICKNESS / 2, CASE_THICKNESS / 2])
      solid_case();
    if (CASE_HAS_HOLES) {
      translate([-CASE_CORNER_RADIUS * 2, 0, 0])
        rotate([90, 0, 90])
        linear_extrude(height=(CASE_WIDTH + CASE_CORNER_RADIUS * 4))
          side_holes_polygon();

      display_hole();
      back_hole();
    }
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

module case_top_mask() {
  // increase radius by 1 so we fully remove the side walls
  radius = CASE_CORNER_RADIUS + 1;
  translate([-radius, -CASE_CORNER_RADIUS, 0])
    cube([
      CASE_WIDTH + radius * 2,
      CASE_DEPTH + CASE_CORNER_RADIUS,
      CASE_HEIGHT + CASE_CORNER_RADIUS * 2,
    ]);
}

module mcu_support() {
  // back supports, which are a bit smaller
  snapping_pin(standoff_height=8);
  translate([15.2 + 2.2, 0, 0])
    snapping_pin(standoff_height=8);

  // front supports (near USB connector)
  translate([0, 43.4 + 2.2, 0])
    snapping_pin(standoff_height=8);
  translate([15.2 + 2.2, 43.4 + 2.2, 0])
    snapping_pin(standoff_height=8);
}

module sensor_support() {
  snapping_pin(standoff_height=25);
  translate([0, 17.8 + 2.2, 0])
    snapping_pin(standoff_height=25);
  translate([10.2 + 2.2, 0, 0])
    snapping_pin(standoff_height=25);
  translate([10.2 + 2.2, 17.8 + 2.2, 0])
    snapping_pin(standoff_height=25);
}

module display_support() {
  translate([CASE_WIDTH - 80, 0, 0]) {
    snapping_pin(standoff_height=1.4);
    translate([72.4 + 2.2, 0, 0])
      snapping_pin(standoff_height=1.4);
    translate([72.4 + 2.2, 39.4 + 2.2, 0])
      snapping_pin(standoff_height=1.4);
    translate([0, 39.4 + 2.2, 0])
      snapping_pin(standoff_height=1.4);
  }
}

module component_supports() {
  translate([0, 0, -CASE_CORNER_RADIUS + CASE_THICKNESS / 2]) {
    // these components are on the bottom face of the case
    translate([3, 10, 0])
      mcu_support();
    translate([40, 33, 0])
      sensor_support();
  }

  // these components are on the front face of the case
  rotate([CASE_ANGLE - 180, 0, 0])
    translate([
      0,
      -CASE_HEIGHT * sin(CASE_ANGLE),
      -CASE_CORNER_RADIUS + CASE_THICKNESS / 2
    ])
    display_support();
}

union() {
  case_shell();
  component_supports();
}
