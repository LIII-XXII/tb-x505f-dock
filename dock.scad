// openscad model paremeters
eps = .1;
$fn = 100;

// Tablet Dock Stand Parameters
// all dimensions in mm

tablet_width = 250;              // Width of the tablet
tablet_height = 150;             // Height of the tablet
tablet_depth = 9.5;              // Depth of the tablet

tablet_pin_depth = 2.9;

dock_width = 200;                // Width of the dock stand
dock_depth = 50;                // Depth of the dock stand
dock_height = 15;               // Height of the dock stand

pin_diameter = 2 - eps;                // Diameter of the pins
pin_width = 3.5 - eps; // probably actually around 4mm, it's hard to measure
pin_length = tablet_pin_depth - 1;                  // Length of the pins
pin_offset = (37.5 + 29.5) / 2 / 2;                 // Offset of the pins from the center

notch_angle = 10;                // Angle of the notch (in degrees)
notch_width = tablet_width;
notch_h = 15; // bezel: 16mm
notch_height = notch_h + tan(notch_angle) * dock_height;  // Height of the notch
notch_depth = tablet_depth + 2 * eps;  // depth of the notch (tablet depth plus an offset)

module trapezoid(w1, w2, h)
{
  
}

module pin_primitive()
{
  cylinder(d1 = pin_diameter, d2= pin_diameter/2, h = pin_length, center = true);
}

module pin_trapezoid(w) // centered
{
  translate([0, -w/2, 0])
    rotate([-90,0,0])
      linear_extrude(height=w)
        projection(cut=false)
          rotate([90, 0, 0])
            pin_primitive();
}

module pin()
{
    spacing = pin_width/2 - pin_diameter/2;
    translate([0, 0, pin_diameter/2])
    union(){
      translate([0, -spacing, 0])
        pin_primitive();
      pin_trapezoid(spacing*2);
      translate([0, spacing, 0])
        pin_primitive();
    }
}


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
          pin();
      rotate([0, notch_angle, 0])
        translate([0, pin_offset / 2, -notch_height/2])
          pin();
    }
  }
}

// Generate the Tablet Dock Stand
tabletDockStand();