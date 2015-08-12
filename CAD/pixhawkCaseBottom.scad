$fn = 100;

length = 123; //actual length is ~80mm
width = 75; //actual width ~54mm
height = 19.9; //actual height is ~15mm

pixL = 83;
pixW = 50;
pixH = 16;

//screw radius
sc = 7.2/2; // 0.25"
h1= 7.5;

difference(){
	cube([length, width, height]);
	translate([7, (width-pixW)/2, 4])cube([pixL, pixW, pixH]);
	//translate([-1, 2.5, 2.5])cube([116, 70, 6]);
	translate([length-24, 10, 5])cube([20, width-20, pixH]);
	//translate([-1, width/2-7.5,15])cube([15, 15, 11]);

}

module foot() {
    module f(){ //boxy inner edge
        translate([-sc*2.9,-sc*2.5,0])cube([sc*2.9,sc*5.,h1]);
        cylinder(h = h1, r=sc*2.5);
    }
	difference(){ //actual hole
		f();
		translate([0,0,-0.1])cylinder(h = h1+1, r=sc);
	}

}

translate([length/2, -sc*2.8, height-h1])rotate([0,0,-90])foot(); //top
translate([length/2, width+sc*2.8, height-h1])rotate([0,0,90])foot(); //top
translate([length/8, -sc*2.8, 0])rotate([0,0,-90])foot();
translate([length/8, width+sc*2.8, 0])rotate([0,0,90])foot();
translate([7*length/8, -sc*2.8, 0])rotate([0,0,-90])foot();
translate([7*length/8, width+sc*2.8, 0])rotate([0,0,90])foot();
