/**
 * All dimensions on this file are in mm.
 */

// Case dimensions
CASE_DEPTH = 55.0;
CASE_HEIGHT = 60.0;
CASE_THICKNESS = 3.0;
CASE_WIDTH = 85.0;

// Case appearence
CASE_ANGLE = 75.0;
CASE_CORNER_RADIUS = 2.5;

// Side-hole settings
CASE_HAS_HOLES = true;
SIDE_HOLE_RADIUS = 2.5;
SIDE_HOLE_DENSITY = 0.35;

// Display PCB settings
DISPLAY_PCB_WIDTH = 80;
DISPLAY_PCB_HEIGHT = 47;

// Misc
EPSILON = 0.1;

$fn = $preview ? 12 : 100;

module snapping_pin(
  board_thickness = 2.0,
  hole_diameter = 1.9,
  snap_cone_diameter = 3,
  snap_cone_height = 4,
  snap_cone_gap_width = 1,
  snap_cone_gap_height = 5,
  standoff_height = 5,
  standoff_width = 3,
  base_height = 2.5,
  base_diameter = 6,
) {
  difference() {
    union() {
      cylinder(h=standoff_height, r=standoff_width / 2);
      translate([0, 0, -base_height])
        cylinder(h=base_height, r=base_diameter / 2);
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
  rotate([90, 0, 90])
    linear_extrude(height=CASE_WIDTH)
      case_side_polygon();
}

module display_hole() {
  SCREEN_OFFSET = 9;
  SCREEN_WIDTH = 62.6;
  SCREEN_HEIGHT = 29.6;

  rotate([CASE_ANGLE - 180, 0, 0])
    translate([
      0,
      -CASE_HEIGHT * sin(CASE_ANGLE),
      -CASE_CORNER_RADIUS - CASE_THICKNESS - EPSILON
    ])
    translate([(CASE_WIDTH - DISPLAY_PCB_WIDTH) / 2, 0, 0])
    translate([SCREEN_OFFSET, SCREEN_OFFSET, 0])
      cube([SCREEN_WIDTH, SCREEN_HEIGHT, CASE_THICKNESS + EPSILON * 2]);
}

module back_hole() {
  translate([0, CASE_DEPTH + CASE_CORNER_RADIUS - 1, 0])
    cube([CASE_WIDTH, CASE_THICKNESS + 2, CASE_HEIGHT]);
}

module case_shell() {
  difference() {
    minkowski() {
      sphere(r=(CASE_THICKNESS + CASE_CORNER_RADIUS));
      solid_case();
    }
    minkowski() {
      sphere(r=CASE_CORNER_RADIUS);
      solid_case();
    }
    if (CASE_HAS_HOLES) {
      translate([-CASE_CORNER_RADIUS - CASE_THICKNESS - EPSILON, 0, 0])
        rotate([90, 0, 90])
        linear_extrude(height=(
          CASE_WIDTH + (CASE_CORNER_RADIUS + CASE_THICKNESS) * 2 + EPSILON
        ))
        intersection() {
          case_side_polygon();
          side_holes_polygon(CASE_DEPTH, CASE_HEIGHT);
        }

      translate([
        0,
        CASE_HEIGHT / tan(CASE_ANGLE),
        CASE_HEIGHT + CASE_CORNER_RADIUS - EPSILON,
      ])
        linear_extrude(height=CASE_THICKNESS)
        side_holes_polygon(CASE_WIDTH, CASE_DEPTH - CASE_HEIGHT / tan(CASE_ANGLE));

      display_hole();
      back_hole();
    }
  }
}

module side_holes_polygon(width, height) {
  intersection() {
    step = SIDE_HOLE_RADIUS / SIDE_HOLE_DENSITY;
    square([width, height]);
    for (x = [-step : step : width + step])
      for (y = [((x / step) % 2) * SIDE_HOLE_RADIUS - step: step : height + step])
        translate([x, y]) circle(r=SIDE_HOLE_RADIUS);
  }
}

module case_top_mask() {
  radius = CASE_CORNER_RADIUS + CASE_THICKNESS + EPSILON;
  translate([-radius, -radius, 0])
    cube([
      CASE_WIDTH + radius * 2,
      CASE_DEPTH + radius,
      CASE_HEIGHT + radius * 2,
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
  HOLE_DIAMETER = 2.4;
  HOLE_DISTANCE_FROM_EDGE = 1.4 + HOLE_DIAMETER / 2;
  STANDOFF_HEIGHT = 1.4;

  translate([(CASE_WIDTH - DISPLAY_PCB_WIDTH) / 2, 0, 0]) {
    translate([HOLE_DISTANCE_FROM_EDGE, HOLE_DISTANCE_FROM_EDGE, 0])
      snapping_pin(standoff_height=STANDOFF_HEIGHT);
    translate([
      DISPLAY_PCB_WIDTH - HOLE_DISTANCE_FROM_EDGE,
      HOLE_DISTANCE_FROM_EDGE,
      0,
    ])
      snapping_pin(standoff_height=STANDOFF_HEIGHT);
    translate([
      DISPLAY_PCB_WIDTH - HOLE_DISTANCE_FROM_EDGE,
      DISPLAY_PCB_HEIGHT - HOLE_DISTANCE_FROM_EDGE,
      0,
    ])
      snapping_pin(standoff_height=STANDOFF_HEIGHT);
    translate([
      HOLE_DISTANCE_FROM_EDGE,
      DISPLAY_PCB_HEIGHT - HOLE_DISTANCE_FROM_EDGE,
      0,
    ])
      snapping_pin(standoff_height=STANDOFF_HEIGHT);
  }
}

module component_supports() {
  translate([0, 0, -CASE_CORNER_RADIUS + EPSILON]) {
    // these components are on the bottom face of the case
    translate([3, 10, 0])
      mcu_support();
    translate([60, 25, 0])
      sensor_support();
  }

  // these components are on the front face of the case
  rotate([CASE_ANGLE - 180, 0, 0])
    translate([
      0,
      -CASE_HEIGHT * sin(CASE_ANGLE),
      -CASE_CORNER_RADIUS + EPSILON
    ])
    display_support();
}

difference() {
  case_shell();
  intersection() {
    component_supports();
    minkowski() {
      sphere(r=(CASE_THICKNESS + CASE_CORNER_RADIUS));
      solid_case();
    }
  }
}
