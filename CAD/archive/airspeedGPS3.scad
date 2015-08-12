

module mount (){
	difference(){
		import("gnss_mount.stl", convexity=6);
		translate([-30,-30,0])cube([60,64,20]);
	}
}

module cover (){
	import("gnss_cover.stl", convexity=6);
}

module meatball (){
	import("meatball.stl", convexity=9);
}

module spacer (){
	import("gnss_spacer.stl", convexity=6);
}

module Pitot_bottom (){
	import("Pitot_bottom.stl", convexity=9);
}

module Pitot_cutout (){
	import("Pitot_cutout.stl", convexity=6);
}

module Pitot_top (){
	import("Pitot_top.stl", convexity=6);
}

module plate(){ //top plate
	
	difference(){ //holes into cover
		cube([85,76,2]);
		translate([65,14,-0.5])cylinder(h=3,r=5);
		translate([65-5,14,-0.5])cylinder(h=3,r=3);
		translate([44,36,-0.5])cube([26,26,3]);
		//translate([50,32,-0.5])cube([17,17,1]);
	}

}

module foot(){
	
	difference(){
		cube([15,15,8]);
		translate([7.5,7.5,-0.5])cylinder(d=6.35,9.5);
	}
}

h = 92;
w = 83;

module mount2(){
		
		depth = 16;
		difference(){
			cube([h,w,depth]);
			translate([3,3,3.25])cube([h-6,w-6,depth+5]);
			translate([26,42,-1])cylinder(h=9,r=4);
		}
}

translate([27,13.5,15])polyhedron(
  points=[ [0,w/2,6], //0
			[0,w/2,-10], //1
			[0,-w/2,-10], //2
			[0,-w/2,6], //3 the four points at base the apex point 
             [20,w/2,-10], //4 
			[20,-w/2,-10]],//5 
  	faces=[ [0,1,4],[5,4,1,2],[5,2,3],[0,4,5,3],[3,2,1,0]          // each triangle side
             ]           // two triangles for square base
 );

//,[2,3,5], [2,3,5,4], [1,2,4,5], [0,1,2,3],[0,1,4], [0,2,5,4]

translate([-19,53.75,5])foot();
translate([-19,-42,5])foot();
translate([-65,-28, 5])mount2();
translate([-61.5,-24.5,21])plate();

// //translate([-30,30,-20]) rotate([90,0,0]) scale([1.2,1.2,1.2]) mount();
// //rotate([-90,0,90]) translate([-40,-40,-40])cover();

//rotate([-90,180,0]) translate([-25,-65,-16])scale([1.2,1.2,1.2])spacer();

//rotate([0,0,-90]) translate([15,33,80]) scale([1.1,1.1,1.1])Pitot_bottom();
//rotate([0,0,-90]) translate([15,39,80]) Pitot_top();	

//rotate([0,0,-90]) translate([0,-23,35])scale([.3,.3,.2]) meatball();
