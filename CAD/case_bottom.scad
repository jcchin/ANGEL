$fn = 20;




length = 145; 
height = 22.6+1.6;
width = 60;
cutout_length = 106;
difference(){
	cube([length, width, height]);
	translate([length-cutout_length,-1,height-7.1])cube([cutout_length+1,1000,40]);
	translate([20,-1,height-1.6])cube([100,65,50]);
	translate([length-5,12.25,15.5-4.8 ])cube([10,12.5,25]); // usb cut out
	translate([length-5,42.25,15.5-4.8 ])cube([10,10.5,25]); //power cut out
	translate([length-cutout_length,2,15.5-9])cube([105-2,width-4,50]); // bottom cutout
}

module peg(){
	//cylinder(d=5, h=2.75);
	translate([0,0,])cylinder(d1=4.5, d2=3.0, h=4.5);
	translate([0,0,4.5])cylinder(d=3,h=1.5);
}

module foot(){
	
	difference(){
		cube([15,15,8]);
		translate([7.5,7.5,-0.25])cylinder(d=6.35,8.5);
	}
}


translate([length,0,15.5-9]){
	translate([-17.24,4.54])peg();
	translate([-15.97,52.8])peg();
	translate([-68.04, 50.26])peg();
	translate([-68.04, 19.78])peg();
	translate([-98.52, 52.8])peg();
	translate([-92.17, 4.54])peg();
}

//accelerometer pins
translate([4.9,width-8.8,height])cylinder(d1=3.1,,d2=2.9, h=3);
translate([4.9,width-32.2,height])cylinder(d1=3.1, d2=2.9, h=3);

//temp pins
translate([26,6.5,height-1.6])cylinder(d1=3.1,,d2=2.9, h=4.6);
translate([26,16.4,height-1.6])cylinder(d1=3.1,,d2=2.9, h=4.6);

//feet
translate([15,-15,0 ])foot(); // foot 1 [-20,-70.5,50]
translate([100,-15,0 ])foot(); // foot 1 [-20,-70.5,50]
translate([15,60,0 ])foot(); // foot 1 [-20,-70.5,50]
translate([100,60,0 ])foot(); // foot 1 [-20,-70.5,50