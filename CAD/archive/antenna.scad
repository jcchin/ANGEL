module ant (){
	difference(){
		import("ant1.stl", convexity=3);
		translate([-110,10,-90])cube([260,260,260]);
	}
}
ant();