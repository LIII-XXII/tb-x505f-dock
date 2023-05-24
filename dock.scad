// openscad model paremeters
eps = .1;
$fn = 100;
// Tablet Dock Stand Parameters
tablet_width = 200;              // Width of the tablet (in mm)
tablet_height = 300;             // Height of the tablet (in mm)
tablet_depth = 10;               // Depth of the tablet (in mm)
dock_width = 200;                // Width of the dock stand (in mm)
dock_depth = 50;                // Depth of the dock stand (in mm)
dock_height = 15;               // Height of the dock stand (in mm)
notch_angle = 30;                // Angle of the notch (in degrees)
pin_diameter = 5;                // Diameter of the pins (in mm)
pin_length = 5;                 // Length of the pins (in mm)
pin_offset = 20;                 // Offset of the pins from the center (in mm)

// Calculate notch dimensions
notch_width = tablet_width;
notch_height = tan(notch_angle) * dock_height;  // Height of the notch
notch_depth = tablet_depth + 2;  // depth of the notch (tablet depth plus an offset)

// Tablet Dock Stand
module tabletDockStand() {
  union() {
    difference() {
      // Base support
      cube([dock_depth, dock_width, dock_height], center = true);

      // Angled notch
      translate([0, 0, dock_height / 2]) {
        rotate([0, notch_angle, 0]) {
          cube([notch_depth, notch_width + eps, notch_height], center = true);
        }
      }
    }

    // Pins
    translate([0, 0, (dock_height) / 2])
    {
      rotate([0, notch_angle, 0])
        translate([0, -pin_offset / 2, -notch_height/2])
          cylinder(d = pin_diameter, h = pin_length*2, center = true);
      rotate([0, notch_angle, 0])
        translate([0, pin_offset / 2, -notch_height/2])
          cylinder(d = pin_diameter, h = pin_length*2, center = true);
    }
  }
}

// Generate the Tablet Dock Stand
tabletDockStand();
