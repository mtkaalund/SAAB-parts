// This is a model of the door speaker holder for a
// SAAB 9-3 1999 
// The original speaker (SAAB part nr: 47 12 642) specs are 
//   nom. 30 W max 60 W 4 ohm

nominal_wall_thickness = 3; // between 2.9 - 3.15 mm

bottom_part_diameter = 120.24;  // inner diameter
bottom_part_height = 42.97;     // inner height

bottom_part_cut_height = 23.24 - nominal_wall_thickness;

middle_part_diameter = 147.88;  // inner diameter
middle_part_height = 25.99;     // inner height

top_part_diameter = 170 - nominal_wall_thickness;      
top_part_height = 7.15;         // inner height

$fn = 100;

// from https://openhome.cc/eGossip/OpenSCAD/SectorArc.html
module sector(radius, angles, fn = 24) {
    r = radius / cos(180 / fn);
    step = -360 / fn;

    points = concat([[0, 0]],
        [for(a = [angles[0] : step : angles[1] - 360]) 
            [r * cos(a), r * sin(a)]
        ],
        [[r * cos(angles[1]), r * sin(angles[1])]]
    );

    difference() {
        circle(radius, $fn = fn);
        polygon(points);
    }
}

module cylinder_diff(inner_diameter, height)
{
    difference()
    {
        // this is the outer part
        cylinder( d = inner_diameter + nominal_wall_thickness, h = height );
        translate([0,0, nominal_wall_thickness ]) {
            cylinder( d = inner_diameter, h = height );
        }
    }
}

module bottom_part()
{
    difference() {
        cylinder_diff( bottom_part_diameter, bottom_part_height );
        translate([-1 * (bottom_part_diameter + 10)/2, 0, -1]) {
            cube([ bottom_part_diameter + 10, 70, bottom_part_height - bottom_part_cut_height + 1]);    
        }
        // this may be changed at a later time
        translate([0,0,bottom_part_height - bottom_part_cut_height - 1 ]) {
            linear_extrude(height = middle_part_height + 2 ) {
                sector( middle_part_diameter, [60, 120], fn = $fn );
            }
        }
    }
}

module middle_part()
{
    difference() {
        cylinder_diff( middle_part_diameter, middle_part_height );

        translate([0,0,-2]) {
            cylinder( d = bottom_part_diameter, bottom_part_height );
        }
        // this may be changed at a later time
        translate([0,0,- middle_part_height + 1.1 ]) {
            linear_extrude(height = middle_part_height + 2 ) {
                sector( middle_part_diameter, [60, 120], fn = $fn );
            }
        }
    }
}

module top_part()
{
    translate([0,0, middle_part_height]) {
        difference() {
        union() {
            difference() {
                cylinder_diff( top_part_diameter - 2 * nominal_wall_thickness , top_part_height);
                translate([0,0,-1]) {
                    cylinder( d = middle_part_diameter, h = middle_part_height);
                }
            }
      // 31 small cylinders
          for( z = [0:31] )
            {
                rotate([0, 0, z*360/31]) {
                    hull() {
                        translate([(top_part_diameter - 2* nominal_wall_thickness)/2 - 2.08/2 - nominal_wall_thickness/2 ,0,0]) {
                            cylinder(d = 2.08, h = top_part_height);
                        }
                        translate([(top_part_diameter - 2* nominal_wall_thickness)/2 + 0.3,0,0]) {
                            cylinder(d = 2.08, h = top_part_height);
                        }
                    }
                }
            }
            // mounting holes
            for( z = [0:4])
            {
                rotate([0, 0, z * 360 / 4 + 45] ) {
                    translate([(top_part_diameter -  nominal_wall_thickness)/2 - 5.87/2 - nominal_wall_thickness/2 ,0,nominal_wall_thickness - middle_part_height/2]) {
                        cylinder(d = 5.87, h = middle_part_height/2);
                    }
                }
            }
        }
    
            for( z = [0:4])
            {
                rotate([0, 0, z * 360 / 4 + 45] ) {
                    translate([(top_part_diameter -  nominal_wall_thickness)/2  - 17.89/3,0,nominal_wall_thickness]) {
                        cylinder(d = 17.89, h = top_part_height);
                    }
                }
            }

            for( z = [0:4])
            {
                rotate([0, 0, z * 360 / 4 + 45] ) {
                    translate([(top_part_diameter -  nominal_wall_thickness)/2 - 5.87/2 - nominal_wall_thickness/2 ,0,0]) {
                        cylinder(d = 5.87/3, h = middle_part_height/2);
                    }
                }
            }
                  
        }
    }
    
    // outer skirt
    difference() {
        cylinder(d = top_part_diameter - nominal_wall_thickness, h = middle_part_height);
        cylinder(d = top_part_diameter - 2 * nominal_wall_thickness, h = middle_part_height * 3, center = true);
    }
}

bottom_part();
translate([0,0,bottom_part_height]) {
    middle_part();

    top_part();
}
