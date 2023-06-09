// openscad model parameters
eps = .1;
$fn = 100;

// Tablet Dock Stand Parameters
// all dimensions in mm

tablet_width = 250;              // Width of the tablet
tablet_height = 150;             // Height of the tablet
tablet_depth = 8.5 + eps;              // Depth of the tablet

tablet_pin_depth = 2.9;

dock_width = 50;                // Width of the dock stand
dock_depth = 75;                // Depth of the dock stand
dock_height = 17;               // Height of the dock stand

pin_diameter = 2;                // Diameter of the pins
pin_width = 3.5; // probably actually around 4mm, it's hard to measure
pin_length = tablet_pin_depth - 1;                  // Length of the pins
pin_offset = (37.5 + 29.5) / 2 / 2;                 // Offset of the pins from the center

notch_angle = 15;                // Angle of the notch (in degrees)
notch_width = tablet_width;
notch_h = 16; // bezel: 16mm
notch_height = notch_h + tan(notch_angle) * dock_height;  // Height of the notch
notch_depth = tablet_depth + 2 * eps;  // depth of the notch (tablet depth plus an offset)


// Higher definition curves
$fs = 0.01;

// from https://danielupshaw.com/openscad-rounded-corners/
// https://gist.github.com/groovenectar/292db1688b79efd6ce11
module roundedcube(size = [1, 1, 1], center = false, radius = 0.5, apply_to = "all") {
	// If single value, convert to [x, y, z] vector
	size = (size[0] == undef) ? [size, size, size] : size;

	translate_min = radius;
	translate_xmax = size[0] - radius;
	translate_ymax = size[1] - radius;
	translate_zmax = size[2] - radius;

	diameter = radius * 2;

	module build_point(type = "sphere", rotate = [0, 0, 0]) {
		if (type == "sphere") {
			sphere(r = radius);
		} else if (type == "cylinder") {
			rotate(a = rotate)
			cylinder(h = diameter, r = radius, center = true);
		}
	}

	obj_translate = (center == false) ?
		[0, 0, 0] : [
			-(size[0] / 2),
			-(size[1] / 2),
			-(size[2] / 2)
		];

	translate(v = obj_translate) {
		hull() {
			for (translate_x = [translate_min, translate_xmax]) {
				x_at = (translate_x == translate_min) ? "min" : "max";
				for (translate_y = [translate_min, translate_ymax]) {
					y_at = (translate_y == translate_min) ? "min" : "max";
					for (translate_z = [translate_min, translate_zmax]) {
						z_at = (translate_z == translate_min) ? "min" : "max";

						translate(v = [translate_x, translate_y, translate_z])
						if (
							(apply_to == "all") ||
							(apply_to == "xmin" && x_at == "min") || (apply_to == "xmax" && x_at == "max") ||
							(apply_to == "ymin" && y_at == "min") || (apply_to == "ymax" && y_at == "max") ||
							(apply_to == "zmin" && z_at == "min") || (apply_to == "zmax" && z_at == "max")
						) {
							build_point("sphere");
						} else {
							rotate = 
								(apply_to == "xmin" || apply_to == "xmax" || apply_to == "x") ? [0, 90, 0] : (
								(apply_to == "ymin" || apply_to == "ymax" || apply_to == "y") ? [90, 90, 0] :
								[0, 0, 0]
							);
							build_point("cylinder", rotate);
						}
					}
				}
			}
		}
	}
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

pogopin_l3 = 1.5;
pogopin_l1 = .3;
module pogopin()
{
  // as given by seller at https://www.amazon.co.jp/dp/B08QHCGNJ8
  d=2 + 4 * eps;
  d1=1.47 + eps;
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
      space_x = 100;
      space_y = 10;
      space_z = 5;
      pogo_z_offset = 0.1; // small offset so that the tablet does not push the pins out
      pogo_z = pogopin_l3-pogopin_l1 + pogo_z_offset;
      pogo_spacing = 3;
    
    difference() {
      // Base support
      roundedcube([dock_depth, dock_width, dock_height], center = true, radius=3, apply_to="z");

      // Angled notch
      translate([0, 0, dock_height / 2]) {
        rotate([0, notch_angle, 0]) {
          roundedcube([notch_depth, notch_width + eps, notch_height], center = true, radius=3);
        }
      }
      
      translate([0, 0, (dock_height) / 2])
      {
        // space for cables (out the back)
        translate([space_x/2-notch_depth, 0, -notch_height/2 - space_z /2 - pogo_z]) {
          roundedcube([100, space_y, space_z+0.5+eps], center=true);
          rotate([0, -7, 0])
            translate([0,0,5])
              roundedcube([100, space_y, space_z+0.5+eps], center=true);
        }
        rotate([0, notch_angle, 0])
        {
          // space for cables
          translate([space_x/2-notch_depth/2, 0, -notch_height/2 - space_z /2 - pogo_z])
            roundedcube([100, space_y, space_z+eps], center=true);
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
    
    // little print support / cable tie thing at the back
    sp_x = 3;
    sp_y = dock_width/2;
    sp_z = 3;
    translate([(dock_depth-sp_x)/2, 0, -(dock_height-sp_z)/2])
        cube([sp_x, sp_y, sp_z], center=true);

    // Pins
    translate([0, 0, (dock_height) / 2])
    {
      rotate([0, notch_angle, 0])
      {
        translate([0, -pin_offset, -notch_height/2])
          pin();
        // small wall to separate pins and avoid conductors touching
        translate([-3, 0, -notch_height/2 - pogo_z])
          cube([10,.4,2], center=true);
        translate([0, pin_offset, -notch_height/2])
          pin();
        }
    }
  }
}

// Generate the dock stand
tabletDockStand();
//pogopin();