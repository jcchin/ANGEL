
//Frame dimensions
l = 130;
w = 170;
r = 4;
h1 = 26; 

//PCB dimensions
lp = 101.6; // 4"
wp = 139.7; // 5.5"


l2 = lp+20;
w2 = wp+20;
h2 = h1-4.5;

//Screw radius
sc = 7.2/2+.1;//3.1; // 0.25"

//through-hole radius
th = 2.6; //2.6mm

//standoff dimensions
h3 = h1-10;

//foot heigh
h4 = 8;

module foot() {
	difference(){
		cylinder(h = 8, r=sc*3);
		translate([0,0,-0.1])cylinder(h = h1+1, r=sc);
	}

}

module foot() {
    module f(){ //boxy inner edge
        translate([-sc*3.9,-sc*2.5,0])cube([sc*3.9,sc*5.,h4]);
        cylinder(h = h4, r=sc*2.5);
    }
	difference(){ //actual hole
		f();
		translate([0,0,-0.1])cylinder(h = h1+1, r=sc);
	}

}



module base(){
	difference(){
		cube([l,w,h4]);
	}
    
    translate([l+3*r,w/2,0])rotate([0,0,0])foot();
    translate([0-3*r,w/2,0])rotate([0,0,180])foot();

}

base();