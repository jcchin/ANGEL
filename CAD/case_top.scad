module caseTop(){
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
	translate([-1, width-11.5, height-15])cube([7.5, 13.5, 20]);
	//translate([0, width- 7.75, height-7])rotate([0,90,0])cylinder(d=9.5, h = 10);
	translate([7.5, width-12.5, height-15])cube([13, 15.5, 14]);
	translate([0, width- 2.25, height-7])rotate([0,90,0])cylinder(d=6.5, h = 10);
	

}

translate([-2, width/4, 3])cube([2, width/2, height-12]);
difference(){
	translate([6.5, width-11.5, height-14.5])cube([15,15.5,14.5]);
	translate([7.5, width-12.5, height-15])cube([13, 15.5, 14]);
	translate([8.5, width-13, height-15])cube([17, 11, 14]); 
	translate([0, width- 2.25, height-7])rotate([0,90,0])cylinder(d=6.5, h = 10);
}
  
translate([0, width-11.5, height-14.4])cube([7.5, 1.5, height-7.1]);	

module foot(){
	translate([0, 11, 0])cube([15, 4, 28.5]);
	difference(){
		cube([15,15,8]);
		translate([7.5,7.5,-0.25])cylinder(d=6.35,8.5);
	}
}

//feet
translate([15, -15, -9.5])foot();
translate([100, -15, -9.5])foot();
difference(){
rotate([0,0,180])translate([-30, -75, -9.5])foot();
translate([7.5, width-12.5, height-15])cube([13, 15.5, 14]);
}
rotate([0,0,180])translate([-115, -75, -9.5])foot();
}

translate([0, 0, 50])caseTop();
//include<case_bottom.scad>

