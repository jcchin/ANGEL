$fn = 20;

length = 145; 
width = 60;
height = 21.5;

difference(){
	cube([length, width, height]);
	translate([2,2,-1])cube([length-4, width-4, height-1]);
	translate([-1,-1,-1])cube([21, 71, 8.1]);
	translate([-1,-1,-1])cube([41, 71, 6.5]);
	translate([length-3, width-7.5-43, -1])cube([10, 43, 13]);
	translate([56, 6, 0])cube([14, 35, 50]);
	translate([-1, width-11.5, height-11])cube([6, 13.5, 12]);
	

}

difference(){
	translate([0, width-13.5, height-12])cube([6.5,13.5,12]);
	translate([-1, width-11.5, height-11])cube([6, 13.5, 12]);
	translate([0, width- 6.75, height-6])rotate([0,90,0])cylinder(d=6.5, h = 10);
	
}
	

module foot(){
	translate([0, 11, 0])cube([15, 6, 28.5]);
	difference(){
		cube([15,15,8]);
		translate([7.5,7.5,-0.25])cylinder(d=6.35,8.5);
	}
}

translate([15, -15, -7.5])foot();
translate([100, -15, -7.5])foot();
rotate([0,0,180])translate([-30, -75, -7.5])foot();
rotate([0,0,180])translate([-115, -75, -7.5])foot();