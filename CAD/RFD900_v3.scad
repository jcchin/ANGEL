h1 = 8;
//Screw radius
sc = 3.1; // 0.25"

module mount(){
	import("RFD900_V2.5.stl", convexity=3);
}

module foot() {
	difference(){
		cylinder(h = h1, r=sc*3);
		translate([0,0,-0.1])cylinder(h = h1+1, r=sc);
	}

}

mount();
foot();