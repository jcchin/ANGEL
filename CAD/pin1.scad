$fn = 20;

l = 22.5;
w = 30;
h = 15;

module BFS (){
	cube([l,w,h]);
}

module PinHole (){
	difference(){
		translate([(l/2)-(1/2),0,h])cube([1,3,5]);
		translate([l/2.2,1.5,h+3.6])rotate([0,90,0])cylinder(d=1.4,h=2);
	}
}

module AGU (){
	translate([l/4,w/4,h])cube([l/2,w/2,h/3]);
}

module Chute (){
	translate([l/4,w/4,h+h/3])cube([l/2,w/2,h/3]);
}

//BFS(); PinHole();
//AGU();

//Chute();

module fullArm(){

	l = 20;
	w = 3;
	h = 3;

	module leftarm (){
		cube([l,w,h-1]);
		translate([l-4.1,-1,-6])cube([2,3,7]);
	}
	module rightarm (){
		cube([l,w,h-1]);
		translate([l-4.1,1,-6])cube([2,3,7]);
	}
	rightarm();
	translate([0,15,0])leftarm();
	difference(){
		translate([(l-4),0,0])cube([6,18,2]);
		translate([(l-2.2),(15/2)+1.2,-0.1])cube([3.3,1.3,4.2]);
	}
}

translate([20.5,-18.1,h+0.2])rotate([0,180,0])fullArm();

module Pin(){
	cylinder(d=1.2,h=5);
}

//translate([-1,-1,0])Pin();

