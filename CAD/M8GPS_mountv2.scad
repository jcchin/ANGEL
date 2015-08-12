/* [Global] */

// Which part would you like to see?
part = "both"; // [both:Lid and base,base:Base only,lid:Lid only]

/* [GPS Box] */

// Size of the GPS board
GpsBase = 52;

// Clearance required below the PCB
UnderDepth = 5;

// Clearance required above the PCB
OverDepth = 8;

// Width of the connection plug
CableHoleH = 13;

// Height of the connection plug
CableHoleW = 16.5;

// Distance of the connection from the edge of the board
CableHolePos = GpsBase/2 - CableHoleW/2 ; //16

// Mounting holes for the base? (Zero=no holes)
MountingCentres = 0;

// Diameter of the mounting holes?
MountingBoltSize = 3;

/* [Advanced Settings] */
// Thickness of the walls, lid and bottom
Thickness = 2.5;

// Width of the shelf that supports the PCB
Shelf = 3.5;

// Roundness of the corners
CornerRadius = 1;

// Thickness of the PCB
PCB = 1.6;

// Diameter of the hole in the lid
Window = 0;

// Extra tolerance for the lid/base fitting
Tolerance = 0.2;

/* [Hidden] */
j = 0.1;
$fn=100;
InnerHeight = UnderDepth + PCB + OverDepth;

BaseInnerLarge = GpsBase + (Tolerance * 2);
BaseInnerSmall = BaseInnerLarge - (Shelf * 2);
BaseOuter = BaseInnerLarge + (Thickness * 2);

LidOuterLip = BaseOuter;
LidOuter = BaseInnerLarge - (Tolerance * 2);
LidInner = LidOuter - (Thickness * 2);

SemiLidOuterLip = LidOuterLip / 2;
SemiLidOuter = LidOuter / 2;
SemiLidInner = LidInner / 2;

module Base()
{
	translate([0, 0, Thickness])
	difference()
	{
		// Walls & floor
		translate([0, 0, -Thickness])
		hull()
		{
			translate([BaseOuter-CornerRadius, GpsBase+Thickness*2-CornerRadius, 0]) cylinder(r = CornerRadius, h = InnerHeight+Thickness);
			translate([CornerRadius, BaseOuter-CornerRadius, 0]) cylinder(r = CornerRadius, h = InnerHeight+Thickness);
			translate([BaseOuter-CornerRadius, CornerRadius, 0]) cylinder(r = CornerRadius, h = InnerHeight+Thickness);
			translate([CornerRadius, CornerRadius, 0]) cylinder(r = CornerRadius, h = InnerHeight+Thickness);
		}
		
		// Deepest cut
		translate([Thickness+Shelf, Thickness+Shelf, 0]) cube([BaseInnerSmall, BaseInnerSmall, InnerHeight]);

		// Shelf
		translate([Thickness, Thickness, UnderDepth]) cube([BaseInnerLarge, BaseInnerLarge, InnerHeight]);
		
		// Hole for wire
		translate([-j, Thickness+CableHolePos, UnderDepth-CableHoleH]) cube([Thickness+Shelf+j*2, CableHoleW, CableHoleH+j]);
        
		// Mounting Holes
		if(MountingCentres > 0)
		{
			translate([-MountingCentres/2, -MountingCentres/2, 0]) translate([BaseOuter * 0.5, BaseOuter * 0.5, -Thickness-j]) cylinder(r = MountingBoltSize/2, h = Thickness+j*2);
			translate([-MountingCentres/2, MountingCentres/2, 0]) translate([BaseOuter * 0.5, BaseOuter * 0.5, -Thickness-j]) cylinder(r = MountingBoltSize/2, h = Thickness+j*2);
			translate([MountingCentres/2, -MountingCentres/2, 0]) translate([BaseOuter * 0.5, BaseOuter * 0.5, -Thickness-j]) cylinder(r = MountingBoltSize/2, h = Thickness+j*2);
			translate([MountingCentres/2, MountingCentres/2, 0]) translate([BaseOuter * 0.5, BaseOuter * 0.5, -Thickness-j]) cylinder(r = MountingBoltSize/2, h = Thickness+j*2);
		}
	}
    
}

module Lid()
{
	translate([SemiLidOuterLip, SemiLidOuterLip, 0])
	union()
	{
		difference()
		{
			// Lid lip
			hull()
			{
				translate([SemiLidOuterLip-CornerRadius,    SemiLidOuterLip-CornerRadius, 0]) cylinder(r = CornerRadius, h = Thickness);
				translate([-SemiLidOuterLip+CornerRadius,  SemiLidOuterLip-CornerRadius, 0]) cylinder(r = CornerRadius, h = Thickness);
				translate([SemiLidOuterLip-CornerRadius,   -SemiLidOuterLip+CornerRadius, 0]) cylinder(r = CornerRadius, h = Thickness);
				translate([-SemiLidOuterLip+CornerRadius, -SemiLidOuterLip+CornerRadius, 0]) cylinder(r = CornerRadius, h = Thickness);
			}
			
			if(Window > 0)
			{
				// GPS Window
				translate([0, 0, -j]) cylinder(r = Window/2, h = Thickness+j*2);
			}
		}

		difference()
		{
			// Outer dimension
			hull()
			{
				translate([SemiLidOuter-CornerRadius,   SemiLidOuter-CornerRadius, j*2]) cylinder(r = CornerRadius, h = OverDepth);
				translate([-SemiLidOuter+CornerRadius, SemiLidOuter-CornerRadius, j*2]) cylinder(r = CornerRadius, h = OverDepth);
				translate([-SemiLidOuter+CornerRadius, -SemiLidOuter+CornerRadius, j*2]) cylinder(r = CornerRadius, h = OverDepth);
				translate([SemiLidOuter-CornerRadius, -SemiLidOuter+CornerRadius, j*2]) cylinder(r = CornerRadius, h = OverDepth);
			}
			
			// Inner dimension
			hull()
			{			
				translate([SemiLidInner-CornerRadius,   SemiLidInner-CornerRadius, j]) cylinder(r = CornerRadius, h = OverDepth+j*2);
				translate([-SemiLidInner+CornerRadius, SemiLidInner-CornerRadius, j]) cylinder(r = CornerRadius, h = OverDepth+j*2);
				translate([-SemiLidInner+CornerRadius, -SemiLidInner+CornerRadius, j]) cylinder(r = CornerRadius, h = OverDepth+j*2);
				translate([SemiLidInner-CornerRadius, -SemiLidInner+CornerRadius, j]) cylinder(r = CornerRadius, h = OverDepth+j*2);
			}
		}
		
	}
}

module print_part()
{
	if (part == "lid")
	{
		translate([GpsBase+Thickness, GpsBase+Thickness, 0]*-0.5)
		Lid();
	} else if (part == "base")
	{
		translate([GpsBase+Thickness, GpsBase+Thickness, 0]*-0.5)
		Base();
		
	} else if (part == "both")
	{
		translate([-(GpsBase+Thickness*3), -(GpsBase+Thickness)*0.5, 0])
		Base();

		//translate([Thickness, -(GpsBase+Thickness)*0.5, 0]) 
		//Lid();
	}
}

difference(){
	print_part();
	translate([-35.25,21,4.5])cube([8.5,12,8]);//usb
	translate([-50.25,21,4.5])cube([8.5,6.6,8]);//usb

}

translate([-GpsBase-Thickness-13,-16,0])cube([9,35,13]); //cover

translate([-GpsBase/1.1,GpsBase/2+11.9,0])rotate([0,0,90])foot();
translate([-GpsBase/1.7,-GpsBase/2-(9.99),0])rotate([0,0,-90])foot();


//translate([-GpsBase*1.1,1,5])cylinder(h=100,r=CableHoleW/2);
module foot() {
    h = 20;
    h1 = h/2;
    //Screw radius
    sc = 7.2/2; // 0.25"
    module f(){ //boxy inner edge
        translate([-sc*2.5,-sc*2.5,0])cube([sc*2.5,sc*5,h1]);
        cylinder(h = h1, r=sc*2.5);
    }
	difference(){ //actual hole
		f();
		translate([0,0,-0.1])cylinder(h = h1+1, r=sc);
	}

}


