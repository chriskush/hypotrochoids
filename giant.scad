TOOTH_MODUL = 5;
PINHOLE_DIAMETER = 5;
PENHOLE_DIAMETER = 10; // Wild guess for standard Sharpies
THICCNESS = 10; // Best to be an odd number of layers (?)
RIM = TOOTH_MODUL * 3;
RIND = 25.4 + 12.7;
PINCOUNT = 12;
TICKWIDTH = 1;
TICKRELIEF = 0.2;
BORE = 25.4 + 6.35;
HOLESTEP = 6.35;
LIPPS=1;

include <hypotrochoids.scad>
use <dovetail.scad>

//ring(144);
//spoked_pinion(66, 6);
// need a gear-tooth nudge? ?? ??? to avoid toothsplitting?
//dovetail(20, 30, 5, 3);

//spoked_split_pinion(66, 4, 8);
//spoked_split_pinion(78, 5, 10);
spoked_split_pinion(102, 6, 12);
//split_ring(144, 12);
