$fn = 20;

length=123;
width=75;
height=7.5;

difference(){
	cube([length,width,height]);
	translate([2.5, 2.5, 2.5])cube([116, 70, 6]);
}
module foot(){
	
	difference(){
		cube([15,15,7.5]);
		translate([7.5,7.5,-0.25])cylinder(d=6.35,8.5);
		
	}
}

translate([length/2 - 7.5, -15, 0])foot();
translate([length/2-7.5, width, 0])foot();

	
	
	
