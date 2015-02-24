$fn = 20;

length = 123; //actual length is ~80mm
width = 75; //actual width ~54mm
height = 9; //actual height is ~15mm


difference(){
	cube([length, width, height]);
	translate([2.5, (width-55)/2, 1])cube([83, 51, 10]);
	//translate([-1, 2.5, 2.5])cube([116, 70, 6]);
	translate([87, 2.5, 1])cube([34, width-5, 10]);
	translate([-1, width/2-7.5,15])cube([15, 15, 10]);



}
module foot(){
	
	difference(){
		cube([15,15,8]);
		translate([7.5,7.5,-0.25])cylinder(d=6.35,8.5);
		
	}
}

translate([length/2 - 7.5, -15, 0])foot();
translate([length/2-7.5, width, 0])foot();
