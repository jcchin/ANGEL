fn = 20;

test = 0; //test piece = 1, real piece = 0;
nub = 1;

innerLength = 72.1; // 2.8" holder length (+ to - of battery)
innerWidth = 74.2; // 2.82" from battery to battery
innerHeight = (test) ? 20 : 109.68 ; //3 batteries stand 4.3" tall
wall = 2; //wall thickness
tol = .4; //tolerance

module DCell (){
	bottom = (test) ? wall/1.5 : wall/1.5; //bottom thickness
	difference(){
		cube([innerLength+ (wall*2), innerWidth + (wall*2), innerHeight + (wall*3)]); 
		translate([wall, wall, bottom])cube([innerLength, innerWidth, innerHeight+40]); //main cavity
		translate([(wall), (-wall),innerHeight+(wall/2)])cube([innerLength, innerWidth+(wall*4.5),wall/1.5]); //slot
		translate([innerLength/2 + (wall/2)-(tol/2),0,innerHeight-(wall/2)+tol])cube([wall+tol,innerWidth+(wall*4.5),wall]); //T-slot
	}
}

module Cover (){

translate([2,85-wall-tol*2,0])cube([innerLength-tol,innerWidth+(wall*3)+tol*3,wall/1.5-tol]); //pl

translate([innerLength/2 + wall/2,85-wall-tol*2,0])cube([wall,wall,wall*2]); //nub
	//translate([2,85,0])cube([innerLength-tol,innerWidth+(wall*2),wall/1.5-tol]); //plate
	translate([2,85+innerWidth+(wall*2),0])cube([innerLength-tol,wall,wall*1.5]); //lip
	translate([innerLength/2 + wall/2,85,wall/1.5-tol])cube([wall,innerWidth+(wall*2),wall-tol*2]); //T-slot
}

//DCell();
Cover();
