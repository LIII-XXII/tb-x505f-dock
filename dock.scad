// openscad model paremeters
eps = .1;
$fn = 100;

// Tablet Dock Stand Parameters
// all dimensions in mm

tablet_width = 250;              // Width of the tablet
tablet_height = 150;             // Height of the tablet
tablet_depth = 8.5 + eps;              // Depth of the tablet

tablet_pin_depth = 2.9;

dock_width = 50;                // Width of the dock stand
dock_depth = 50;                // Depth of the dock stand
dock_height = 15;               // Height of the dock stand

pin_diameter = 2;                // Diameter of the pins
pin_width = 3.5; // probably actually around 4mm, it's hard to measure
pin_length = tablet_pin_depth - 1;                  // Length of the pins
pin_offset = (37.5 + 29.5) / 2 / 2;                 // Offset of the pins from the center

notch_angle = 10;                // Angle of the notch (in degrees)
notch_width = tablet_width;
notch_h = 16; // bezel: 16mm
notch_height = notch_h + tan(notch_angle) * dock_height;  // Height of the notch
notch_depth = tablet_depth + 2 * eps;  // depth of the notch (tablet depth plus an offset)

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

pogopin_l3 = 1.5;
pogopin_l1 = .3;
module pogopin()
{
  // as given by seller at https://www.amazon.co.jp/dp/B08QHCGNJ8
  d=2 + 2 * eps;
  d1=1.47;
  d2=1 + eps;
  l2=.5; // assuming spring travel distance = pin size
  l3=pogopin_l3;
  l=2;
  l1=pogopin_l1 + eps;
  union() {
    cylinder(h=l1, r=d/2); // base
    cylinder(l3, r=d1/2); // body
    translate([0, 0, l3]){
      cylinder(h=l1, r1=d1/2, r2=d2/2+eps); // chamfered neck
      translate([0, 0, l1]){
        cylinder(h=l2, r1=d2/2, r2=d2/4); // pin
      }
    }
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
      

      

      space_x = 100;
      space_y = 10;
      space_z = 5;
      pogo_z = pogopin_l3-pogopin_l1;
      pogo_spacing = 3;
      
      translate([0, 0, (dock_height) / 2])
      {
        // space for cables (out the back)
        translate([space_x/2-notch_depth/2, 0, -notch_height/2 - space_z /2 - pogo_z])
          cube([100, space_y, space_z], center=true);
        rotate([0, notch_angle, 0])
        {
          // space for cables
          translate([space_x/2-notch_depth/2, 0, -notch_height/2 - space_z /2 - pogo_z])
            cube([100, space_y, space_z], center=true);
          // pogo pins
          translate([0, 0, -notch_height/2 - pogo_z]) {
            translate([0, -pogo_spacing/2, 0])
              pogopin();
            translate([0, pogo_spacing/2, 0])
              pogopin();
          }
        }
      }
    }

    // Pins
    translate([0, 0, (dock_height) / 2])
    {
      rotate([0, notch_angle, 0])
        translate([0, -pin_offset, -notch_height/2])
          pin();
      rotate([0, notch_angle, 0])
        translate([0, pin_offset, -notch_height/2])
          pin();
    }
  }
}

// Generate the Tablet Dock Stand
tabletDockStand();
//pogopin();