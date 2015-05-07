
//Frame dimensions
l = 130;
w = 170;
r = 4;
h1 = 8;

//PCB dimensions
lp = 101.6; // 4"
wp = 139.7; // 5.5"


l2 = lp+20;
w2 = wp+20;
h2 = 5.5;

//Screw radius
sc = 3.1; // 0.25"

//through-hole radius
th = 2.6; //2.6mm

module foot() {
	difference(){
		cylinder(h = h1, r=sc*3);
		translate([0,0,-0.1])cylinder(h = h1+1, r=sc);
	}

}

module standoff(){
	difference(){
		cylinder(h=h1, r=th+2);
		cylinder(h=h1+2, r = th);
	}
}

module base(){
	difference(){
		cube([l,w,h1]);
		translate([(l-l2)/2, (w-w2)/2, h1-h2+0.1])cube([l2,w2,h2]);
	}
	translate([lp+(l-lp)/4,wp+(w-wp)/4,-0.1])standoff();
	translate([3*(l-lp)/4,wp+(w-wp)/4,-0.1])standoff();
	translate([3*(l-lp)/4,3*(w-wp)/4,-0.1])standoff();
	translate([lp+(l-lp)/4,3*(w-wp)/4,-0.1])standoff();
	
	translate([l-3*r,w+1.7*r,0])foot();
	translate([0+3*r,0-1.7*r,0])foot();
	translate([0+3*r,w+1.7*r,0])foot();
	translate([l-3*r,0-1.7*r,0])foot();

}

base();