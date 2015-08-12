
//Frame dimensions
l = 130;
w = 190;
r = 4;
h1 = 40; 

//PCB dimensions
lp = 100; // 4"
wp = 160; // 5.5"
holeY = 77;
holeX = 150;


l2 = lp+20;
w2 = wp+20;
h2 = h1-3.5;

//Screw radius
sc = 7.2/2+.1;//3.1; // 0.25"

//through-hole radius
th = 2.8; //2.6mm

//standoff dimensions
h3 = 20;

//foot heigh
h4 = 7.2;

module foot() {
	difference(){
		cylinder(h = 8, r=sc*2.5);
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

module standoff(){
	difference(){
		cylinder(h=h3, r=th*3);
		cylinder(h=h3+2, r = th);
        translate([0,0,-0.1])cylinder(h=2, r = th*2);
	}
}

module base(){
	difference(){
		cube([l,w,h1]);
		translate([(l-l2)/2, (w-w2)/2, h1-h2+0.1])cube([l2,w2,h2]);
        translate([(l-l2/3)/2, (w-w2/3)/2, -0.1])cube([l2/3,w2/3,h2]); //cutout
        translate([-0.1,51.5,15])cube([10,15,10]); //pixhawk
        translate([-0.1,115,17])cube([10,25,14]); //cameras
        translate([47,w-10,17])cube([17,20,16]); //arduino
        translate([120,132,17])cube([12,23,14]); //accelerometers
        translate([58,-1,16])cube([18,23,12]); //power switch
        translate([l-10,95,4])cube([15,20,14]); //radio
        translate([(l-holeY)/2+holeY,(w-holeX)/2+holeX+0.75,-6.01])cylinder(h=10, r = th*2);
        translate([(l-holeY)/2,(w-holeX)/2+holeX+0.75,-6.01])cylinder(h=10, r = th*2); //top right
        translate([(l-holeY)/2,(w-holeX)/2,-6.01])cylinder(h=10, r = th*2); //top left (origin)
        translate([(l-holeY)/2 + holeY,(w-holeX)/2,-6.01])cylinder(h=10, r = th*2); //bottom left
	}
    
    
	translate([(l-holeY)/2+holeY,(w-holeX)/2+holeX+0.75,0.01])standoff(); //bottom right
	translate([(l-holeY)/2,(w-holeX)/2+holeX+0.75,0.01])standoff(); //top right
	translate([(l-holeY)/2,(w-holeX)/2,0.01])standoff(); //top left (origin)
	translate([(l-holeY)/2 + holeY,(w-holeX)/2,0.01])standoff(); //bottom left
	
	translate([l-3*r,w+3*r,0])rotate([0,0,90])foot();
	translate([0+3*r,0-3*r,0])rotate([0,0,-90])foot();
	translate([0+3*r,w+3*r,0])rotate([0,0,90])foot();
	translate([l-3*r,0-3*r,0])rotate([0,0,-90])foot();
    
    translate([0.75*l,-3*r,h1-h4])rotate([0,0,-90])foot();
    translate([l/4,w+3*r,h1-h4])rotate([0,0,90])foot();

}

module cover(){
	difference(){
		cube([l,w,h4]);
        translate([l/2-6,20,-1])cube([19,23,14]); //power switch
        
	}
    
    translate([0.75*l,-3*r,0])rotate([0,0,-90])foot();
    translate([l/4,w+3*r,0])rotate([0,0,90])foot();
    
    
}

//difference(){

base();
//translate([-0.1,-0.1,-0.1])cube([l+0.2,w+0.2,4.4]);
//translate([-0.1,-0.1,9])cube([l+0.2,w+0.2,30]);    
//}

//translate([0,0,100])cover();