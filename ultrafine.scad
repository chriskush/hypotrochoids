TOOTH_MODUL = 1;
PINHOLE_DIAMETER = 1.50; // Measured a pushpin @1.14
PENHOLE_DIAMETER = 1.65; // Measured Sharpie Ultra Fine Pt @1.4something
THICCNESS = 2.20; // Best to be an odd number of layers (?)
RIM = TOOTH_MODUL * 3;
RIND = 15;
PINCOUNT = 12;
TICKWIDTH = 1;
TICKRELIEF = 0.2;
BORE = 3;
HOLESTEP = 1;
LIPPS=1;

include <hypotrochoids.scad>

pinion(88);
