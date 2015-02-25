

module arm (){
	difference(){
		
		scale([0.5,1,1])import("csbf_separation_arm_left.stl", convexity=6);
		translate([0.1,0.65,-1])cube([0.5,1,2]);
	}
}


module plate (){
	difference(){
		
		import("gondola_top_panel.stl", convexity=6);
		translate([-30,-20,-7])cube([80,80,30]);
		translate([-14,-8,-15])cube([10,10,10]);
		translate([4,-8,-15])cube([10,10,10]);
		
	}
}

module tab (){
	difference(){
		rotate([0,0,90])import("mcmaster-carr_release_tab.stl", convexity=6);
		//translate([-30,-30,0])cube([60,64,20]);
	}
}

module pin (){
	difference(){
		scale([0.75,1,1])import("pin.stl", convexity=6);
	}
}

translate([0,-0.5,0])tab();
arm();
translate([0,14,-1])rotate([-90,0,0])plate();
pin();