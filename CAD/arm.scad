$fn = 20;


module fullArm(){

	l = 14;
	w = 3;
	h = 3;

	module leftarm (){
		cube([l,w,h-1]);
		translate([l-4.1,-1,-4])cube([2,3,5]);
	}
	module rightarm (){
		cube([l,w,h-1]);
		translate([l-4.1,1,-4])cube([2,3,5]);
	}
	rightarm();
	translate([0,15,0])leftarm();
	difference(){
		translate([(l-4),0,0])cube([6,18,2]);
		translate([(l-2.5),(15/2)+1,-0.1])cube([3,1,4]);
	}
}

translate([16.5,-12,h+0.2])rotate([0,0,90])fullArm();