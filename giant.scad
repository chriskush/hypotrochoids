TOOTH_MODUL = 5;
PINHOLE_DIAMETER = 3;
PENHOLE_DIAMETER = 5; // Measured Sharpie Ultra Fine Pt @1.4something
THICCNESS = 6.60; // Best to be an odd number of layers (?)
RIM = TOOTH_MODUL * 3;
RIND = 15;
PINCOUNT = 12;
TICKWIDTH = 1;
TICKRELIEF = 0.2;
BORE = 15;
HOLESTEP = 12.7;
LIPPS=1;

include <hypotrochoids.scad>

ring(144);
//spoked_pinion(66, 8);
