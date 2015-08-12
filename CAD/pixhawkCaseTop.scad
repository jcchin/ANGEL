module caseTop(){
$fn = 100;

length=123;
width=75;
height=20;
//screw radius
sc = 7.2/2; // 0.25"
h1= 8;
translate([0,width/2-8,0])cube([16,16,height]);
   
difference(){
	cube([length,width,height]);
	translate([6,6,-1])cube([length-12, width-12, height-1.5]);
	translate([length-10, width/2 - 5, height-15])cube([20, 10, 7]); //usb
	translate([length-10, width/2-8, height-11.5])rotate([0,90,0])cylinder(d=2, 12); //usb screw
	translate([length-10, width/2+8, height-11.5])rotate([0,90,0])cylinder(d=2, 12); //usb screw
	//translate([length-20, width/2-8, height-3])cylinder(d=8.5, 10);
	//translate([length-22, width/2+8, height-3])cube([4,4,10]);
	//translate([length-26, width/2+14, height-3])cylinder(d=2,10);
	//translate([length-26, width/2+6, height-3])cylinder(d=2,10);
	translate([width/2-1.5, width/2-20,0])cube([5,7,100]); //window2
    translate([width/2-7.5, width/2,0])cylinder(h=25, r = 4); //windowLED
    translate([width/2-1.5, width/2+13,0])cube([5,7,100]); //window3
	//translate([-1, width/2-7.5, -1])cube([15,15,10]); //sd slot
}

module foot() {
    module f(){ //boxy inner edge
        translate([-sc*10.9,-sc*2.5,0])cube([sc*10.9,sc*5.,height]);
        cylinder(h = h1, r=sc*2.5);
    }
	difference(){ //actual hole
		f();
		translate([0,0,-0.1])cylinder(h = h1+1, r=sc);
	}

}

difference(){
    translate([length/2, -sc*2.8, 0])rotate([0,0,-90])foot();
    translate([length/2-10, -sc*2.9, 8])cube([30,10,14]);
}
difference(){
    translate([length/2, width+sc*2.8, 0])rotate([0,0,90])foot();
    translate([length/2-10, width+0.4, 8])cube([30,10,14]);
}
}
translate([0,0,10])caseTop();
//include<pixhawkCaseBottom.scad>;
