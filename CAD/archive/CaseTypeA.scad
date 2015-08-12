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