sc = 7.2/2+.1; // 0.25"
h1= 10.6;
module caseTop(){
$fn = 100;

length = 151; //145
width = 60;
height = 24.5;
//screw radius
sc = 7.2/2+.1; // 0.25"
h1= 33.6;
    
difference(){
	cube([length, width+12, height]);
	translate([2,8,-1])cube([length-10, width-4, height-1]);
	//translate([-1,-1,-1])cube([24, 73, 2.4]); //step up
	//translate([-1,-1,-1])cube([41, 71, 6.5]);
	//translate([length-3, width-7.5-43, -1])cube([10, 43, 13]); //sd window
	translate([134, 32, 0])cube([5, 8, 50]); //LED window
	//translate([-1, width-11.5, height-15])cube([7.5, 13.5, 20]);
	translate([-0.1, width- 4, height-11.])rotate([0,90,0])cylinder(d=9.5, h = 11);
    
    translate([-0.1, width- 24, height-7.])rotate([0,90,0])cylinder(d=4, h = 11);
    
    translate([-0.1, width- 34, height-19])rotate([0,90,0])cylinder(d=4, h = 11);
    
    translate([-0.1, width- 46, height-19])rotate([0,90,0])cylinder(d=4, h = 11);
	//translate([7.5, width-12.5, height-15])cube([13, 15.5, 14]);
	//translate([0, width- 2.25, height-7])rotate([0,90,0])cylinder(d=6.5, h = 10);
	
}

difference(){ //lip
    
    translate([-3, width/4+3, -6])cube([3, width/2, height-4]);
    translate([-0.5, width/4-3.1, -7])cube([0.7, width/2+.2, height-12]);
    translate([-5,26,5.6])rotate([0,90,0])cylinder(d=4, h = 11);
}



//feet
translate([12, -14, 0])rotate([0,0,-90])foot();
translate([130, -14, 0])rotate([0,0,-90])foot();
difference(){
rotate([0,0,180])translate([-12, -86, 0])rotate([0,0,-90])foot();
}
rotate([0,0,180])translate([-130, -86, 0])rotate([0,0,-90])foot();


//stiffener
translate([115, -3.9,0])cube([4,4,height+0.2]); 
translate([115,width+11.9,0 ])cube([4,4,height+0.2]); 
translate([length-0.1,width/3,0 ])cube([4,4,height+0.2]);
translate([length-0.1,4*width/5,0 ])cube([4,4,height+0.2]);

}

module foot() {
    module f(){ //boxy inner edge
        translate([-sc*3.9,-sc*2.5,0])cube([sc*3.9,sc*5.,h1]);
        cylinder(h = h1, r=sc*2.5);
    }
	difference(){ //actual hole
		f();
		translate([0,0,-0.1])cylinder(h = h1+1, r=sc);
	}



}
translate([0, 0, 35])caseTop();
//include<arduinoCaseBottom.scad>


/*
module foot() {
    module f(){ //boxy inner edge
        translate([-sc*3.9,-sc*2.5,0])cube([sc*3.9,sc*5.,h1]);
        cylinder(h = h1, r=sc*2.5);
    }
	difference(){ //actual hole
		f();
		translate([0,0,-0.1])cylinder(h = h1+1, r=sc);
        translate([-8.5,-10,10])cube(30,20,10);
	}

}
*/