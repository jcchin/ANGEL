$fn = 20;

length = 50.675; // actual length of piece is 41.75
width = 26.6375; // actual width is 20.6375
height = 32.9875; //actual height is 26.9875
widthB = width-3.4;

module casetypeA(){
length = 50.675; // actual length of piece is 41.75
width = 26.6375; // actual width is 20.6375
height = 32.9875; //actual height is 26.9875

difference(){
cube([length, width, height]);
translate([2.4, 0.5, 1])cube([length-4.8, width - 4.8, 50]);
translate([1, -1, height - 2.4])cube([length-2, width, 1.6]);
translate([2.4, -1.8, height -2.4])cube([length-4.8, 5, 50]);
translate([4, -1, height-10])cube([5, 10, 50]);
translate([length - 9, -1, height-10])cube([5, 10, 50]);
//translate([-1, width-10, height-10])cube([length + 10 ,5,7]);

}
}

//translate([15.7, width/2, 0])cylinder(d = 2.575, h = 3.6);
//translate([15.7+17.4625, width/2, 0])cylinder(d = 2.575, h = 3.6);
//translate([(length/2)-1, -0.5, height -3])cube([2, 0.5, 1]);


module casetypeB(){
length = 50.675; // actual length of piece is 41.75
width = 26.6375; // actual width is 20.6375
height = 32.9875; //actual height is 26.9875

difference(){
cube([length, width-3.4, height]);
translate([2.4, 0.5, 1])cube([length-4.8, width - 4.8, 50]);
translate([1, -1.8, height - 2.4])cube([length-2, width+2.4, 1.6]);
translate([2.4, -1.8, height -2.4])cube([length-4.8,50, 50]);
translate([4, -1, height-10])cube([5, 50, 50]);
translate([length - 9, -1, height-10])cube([5, 50, 50]);
} 

//translate([15.7, width/2, 0])cylinder(d = 2.575, h = 3.6);
//translate([15.7+17.4625, width/2, 0])cylinder(d = 2.575, h = 3.6);
//translate([(length/2)-1, -0.5, height -3])cube([2, 0.5, 1]);
}

module casetypeC(){
length = 50.675; // actual length of piece is 41.75
width = 26.6375; // actual width is 20.6375
height = 32.9875; //actual height is 26.9875

difference(){
cube([length, width-1.9, height]);
translate([2.4, 2.4, 1])cube([length-4.8, width - 4.8, 50]);
translate([1, -1.8, height - 2.4])cube([length-2, width+2.4, 1.6]);
translate([2.4, -1.8, height -2.4])cube([length-4.8,50, 50]);
translate([4, -1, height-10])cube([5, 50, 50]);
translate([length - 9, -1, height-10])cube([5, 50, 50]);
}
}


module caseside(){
casetypeA();
translate([0, -widthB,0])casetypeB();
translate([0, -widthB*2,0])casetypeB();
translate([0, -widthB*2-(width-1.9),0])casetypeC();


translate([length,0,0])casetypeA();
translate([length, -widthB,0])casetypeB();
translate([length, -widthB*2,0])casetypeB();
translate([length, -widthB*2-(width-1.9),0])casetypeC();

translate([length*2,0,0])casetypeA();
translate([length*2, -widthB,0])casetypeB();
translate([length*2, -widthB*2,0])casetypeB();
translate([length*2, -widthB*2-(width-1.9),0])casetypeC();

}

module sidehole(){
rotate([0, 90, 0])translate([-height/2, width/2, -1])cylinder(d=3.175,h=10000);
}

module side(){
difference(){
caseside();
translate([10, width-10,-1])cylinder(d = 3.175, h = 5);
translate([10, -(widthB*3)+10,-1])cylinder(d = 3.175, h = 5);
translate([(length*3)-10, width-10,-1])cylinder(d = 3.175, h = 5);
translate([(length*3)-10, -(widthB*3)+10,-1])cylinder(d = 3.175, h = 5);

translate([0,-2,(height/4)+1])sidehole();
translate([0,-(widthB)-2,(height/4)+1])sidehole();
translate([0,-2*(widthB)-2,(height/4)+1])sidehole();
//translate([(length*3)-3,0,0])sidehole();
//translate([(length*3)-3,(-3)*width,0])sidehole();
translate([0,((-3)*widthB)-2,(height/4)+1])sidehole();
//translate([2.4, -(width*3)-2.4 , height-2.4])cube([100, (width*4), 100]);
//translate([length-3.4, width-3.4, height-2.4])cube([60, 2.4, 1.6]); 
}
//translate([5,-width*3, height]) cube([63,101,6.3]);
//translate([70,-width*3, height]) cube([63,101,6.3]);
}




side();
//rotate([0,180,0])translate([-length*3, 0,0])side();









