l = 37.5;
w = 62;
h = 20;
$fn=100;
h1 = h/2;
//Screw radius
sc = 7.2/2; // 0.25"
//Antenna radius
ar = 7.2;


module box(){
	difference(){
		cube([1.2*l,1.2*w,1.1*h]);
		translate([0.1*l,0.1*w, h/3])cube([l,w+0.5, h+0.1]);
        translate([1.2*l/2,h1/1.2,h/2])rotate([90,0,0])cylinder(h=h1*2, r=ar);
        //translate([1.1*l/4,4.7*w/5,-0.1])cube([1.1*l/2,6,10]);
	}
    
    
}

module foot() {
    module f(){ //boxy inner edge
        translate([-sc*4,-sc*2.5,0])cube([sc*4.1,sc*5,h1]);
        cylinder(h = h1, r=sc*2.5);
    }
	difference(){ //actual hole
		f();
		translate([0,0,-0.1])cylinder(h = h1+1, r=sc);
	}

}


module DigiMount(){
	translate([1.15*l+sc*4.5,1.15*w/2,0])foot();
	translate([-sc*4.,1.15*w/2,0])rotate([0,0,180])foot();
	box();
}

DigiMount();

module cover(){
    difference(){
        cube([1.5*l,1.5*w,16]);
        translate([.15*l,0.15*w,-0.1])cube([1.21*l,1.21*w,10]);
        translate([l/2,w-6,-0.25])cube([l/2,w/6,16.5]);
        translate([1.5*l/2,h1+1.1,0])rotate([90,0,0])cylinder(h=h1*2, r=ar+1);
    }

    scale([1,1,6/h1])translate([1.5*l+sc*2.49,1.45*w/2,0])foot();
	scale([1,1,6/h1])translate([-sc*2.49,1.45*w/2,0])rotate([0,0,180])foot();
}

translate([-.15*l,-.15*w,10])cover();