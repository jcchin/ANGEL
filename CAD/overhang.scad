$fn = 100;


difference(){
    cube([6,24,3]);
    rotate([90,0,0])translate([3,1.5,-24])cylinder(d=0.8,h=25);
    translate([1.5,1,-.5])cube([3,1.,2.5]);
    rotate([90,0,0])translate([3,1.5,-4])cylinder(d=1.5,h=20);
    translate([1.5,-2.,1.5])cube([3,20,1.]);
}

color([1,0,0])rotate([90,0,0])translate([3,1.5,-24])cylinder(d=0.6,h=25);

//bearing
color([0,1,1])rotate([90,0,0])translate([3,1.5,-4])cylinder(d=1.5,h=2);
color([0,1,1])translate([1.5,2.,1.5])cube([3,2,1.]);