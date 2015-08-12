$fn = 20;

l = 15;
w = 20;
h = 10;

module BFS (){
	cube([l,w,h]);
}

module PinHole (){
	difference(){
		translate([(l/2)-(.75/2),0,h])cube([.75,2,4]);
		translate([l/2.2,1,h+2.8])rotate([0,90,0])cylinder(d=1,h=2);
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

//translate([16.5,-12,h+0.2])rotate([0,0,90])fullArm();

module Pin(){
	cylinder(d=.8,h=5);
}

translate([-1,-1,0])Pin();

