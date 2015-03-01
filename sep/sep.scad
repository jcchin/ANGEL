

module arm (){
	difference(){
		
		scale([0.25,1,1])import("csbf_separation_arm_left.stl", convexity=6);
		translate([0.01,0.59,-1])cube([0.6,1.1,2]);
	}
}

module bolt (){
	difference(){
		
		rotate([90,0,90])import("gondola_eyebolt_6097k370.stl", convexity=6);
		translate([-0.5,-0.55,-2.2])cube([1,1.1,2.25]);
	}
}

module boltNut (){
	difference(){
		translate([-0.5,-0.55,-1.75])cube([1,1.1,0.5]);
		rotate([90,0,90])import("gondola_eyebolt_6097k370.stl", convexity=6);
		
	}
}



module plate (){
	difference(){
		
		import("gondola_top_panel.stl", convexity=6);
		translate([-30,-19,-8])cube([80,80,30]);
		translate([-13,-8,-15])cube([10,10,10]);
		translate([3,-8,-15])cube([10,10,10]);
		translate([0,-.5,-8.9])rotate([0,90,90])scale([1.05,1.05,1.05])bolt ();
		
	}
}

module tab (){
	difference(){
		rotate([0,0,90])import("mcmaster-carr_release_tab.stl", convexity=6);
		translate([-1,0,-0.53])cube([2,3,1]);
	}
}


module tab2 (){
	difference(){
		rotate([0,0,90])import("mcmaster-carr_release_tab.stl", convexity=6);
		translate([-1,1.12,-0.535])cube([1.2,1,1]);
		translate([-1.5,0.12,-0.535])cube([1.2,3,1]);
	}
}

module pin (){
	difference(){
		scale([0.75,1,1])import("pin.stl", convexity=6);
	}
}

module armCut (){

	translate([1.4,-0.5,-0.25])tab();
	arm();
}
//scale([25.4, 25.4, 25.4])armCut();
scale([25.4, 25.4, 25.4])tab();
//scale([25.4, 25.4, 25.4])translate([0,14,-1])rotate([-90,0,0])plate();
//scale([25.35, 25.35, 25.35])pin();
//scale([25.4, 25.4, 25.4])translate([0.3,1.13,-1.5])bolt();
//scale([25.4, 25.4, 25.4])boltNut();