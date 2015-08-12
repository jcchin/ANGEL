$fn = 100;

length = 151; //145
height = 22.6+1.6;
width = 60; //60
cutout_length = 112;
//screw radius
sc = 7.2/2+.1; // 0.25"
h1= 10.6;
difference(){
	cube([length, width+12, height+10]);
	 
    translate([20+2.8,-1,height-1.6+10])cube([30,75,40]); //shelf
	translate([length-11,12.25+5,15.5-4.8 ])cube([15,12.5,25]); // usb cut out
	translate([length-11,43.25+5,15.5-4.8 ])cube([15,9.5,25]); //power cut out
	translate([length-cutout_length,8,15.5-9])cube([105-2,width-4,50]); // bottom cutout
}
translate([length-0.1, width/2-0.25,0])cube([5,5,height+10]); //stiffener
translate([length-0.1, width/2+13.25,0])cube([5,5,height+10]); //stiffener

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

module peg(){
	//cylinder(d=5, h=2.75);
	translate([0,0,])cylinder(d1=4.5, d2=3, h=4.5);
	translate([0,0,4.5])cylinder(d=3,h=3.1);
}

translate([length,0,4.5]){ //mega pins
	translate([-18.84-6,5.64+6])peg();
	translate([-17.57-6,54.4+6])peg();
	translate([-69.96-6, 49.26+6])peg();
	translate([-69.96-6, 20.98+6])peg();
	translate([-101.02-6, 54.3+6])peg();
	translate([-94.47-6, 5.74+6])peg(); 
}



//accelerometer pins
//translate([4.7,width-16.3,height])cylinder(d1=3.1,,d2=2.9, h=4.6);
//translate([4.7,width-39.7,height])cylinder(d1=3.1, d2=2.9, h=4.6);

//temp pins
//translate([26,6.5,height-1.6])cylinder(d1=3.1,,d2=2.9, h=4.6);
//translate([26,16.4,height-1.6])cylinder(d1=3.1,,d2=2.9, h=4.6);

//feet
translate([35,-14,0 ])rotate([0,0,-90])foot(); // foot 1 [-20,-70.5,50]
translate([100,-14,0 ])rotate([0,0,-90])foot(); // foot 1 [-20,-70.5,50]
translate([35,width+14+12,0 ])rotate([0,0,90])foot(); // foot 1 [-20,-70.5,50]
translate([100,width+14+12,0 ])rotate([0,0,90])foot(); // foot 1 [-20,-70.5,50

//feet2
translate([12,-14,23.6 ])rotate([0,0,-90])foot(); // foot 2 [-20,-70.5,50]
translate([130,-14,23.6 ])rotate([0,0,-90])foot(); // foot 2 [-20,-70.5,50]
translate([12,width+14+12,23.6 ])rotate([0,0,90])foot(); // foot 1 [-20,-70.5,50]
translate([130,width+14+12,23.6 ])rotate([0,0,90])foot(); // foot 1 [-20,-70.5,50

//side stiffeners
translate([115, -3.9,0])cube([4,4,height+10]); //stiffener
translate([115,width+11.9,0 ])cube([4,4,height+10]); //stiffener