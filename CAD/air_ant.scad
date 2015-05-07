module ant(){
	difference(){
		import("airborne_antenna.stl", convexity=5);
		
	}
	
}

module  antS(){
	difference(){
	scale([25.4,25.4,25.4])ant();
	translate([-95,-0.1,-95])cube([190,6.1,190]);
	}
	
}

antS();