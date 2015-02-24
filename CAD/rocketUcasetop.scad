module caseTop(){
$fn = 20;

length=123;
width=75;
height=20;

difference(){
	cube([length,width,height]);
	translate([2.5,2.5,-1])cube([length-5, width-5, height-1.5]);
	translate([length-5, width/2 - 5, height-15])cube([10, 10, 7]);
	translate([length-5, width/2-8, height-11.5])rotate([0,90,0])cylinder(d=2, 10);
	translate([length-5, width/2+8, height-11.5])rotate([0,90,0])cylinder(d=2, 10);
	translate([length-20, width/2-8, height-3])cylinder(d=8.5, 10);
	translate([length-22, width/2+8, height-3])cube([4,4,10]);
	translate([length-26, width/2+14, height-3])cylinder(d=2,10);
	translate([length-26, width/2+6, height-3])cylinder(d=2,10);
	translate([width/2-5, width/2-5,0])cube([10,10,100]);
	translate([-1, width/2-7.5, -1])cube([15,15,10]);
}


module foot(){
	translate([0, 11, 0])cube([15, 4, 15]);
	difference(){
		cube([15,15,5]);
		translate([7.5,7.5,-0.25])cylinder(d=6.35,8.5);
	}
}




translate([length/2-7.5, -15, -1])foot();
rotate([0,0,180])translate([-length/2-7.5, -90, -1])foot();
}
translate([0,0,10])caseTop();
//include<rocketUcasebottom.scad>;
module heater(){
include<rocketUheatercomp.scad>;
}
//translate([0, 0,-8.5])heater();