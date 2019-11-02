// Ring or wheel?
Part_Type = "Wheel"; // ["Wheel", "Ring"]

// How many teeth?
Tooth_Count = 66;

// Split into how many parts?
Splits = 1;

// Tooth rise/fall above ideal circle.
Tooth_Module = 5;

// Radial increment for wheel pen-holes.
Wheel_Hole_Step = 6.35;

// Radius of unusable center area of wheels.
Wheel_Bore = 31.75;

// Amount of unusable outer part of wheels.
Wheel_Rim = Tooth_Module * 3;

// Breadth of ring segments.
Ring_Rind = 25.4 + 12.7;

// Thickness of parts (at gear teeth).
Part_Thickness = 10;

// Diameter of fixing-holes for rings.
Pinhole_Diameter = 5;

// Diameter of pen-holes for wheels.
Penhole_Diameter = 10;

// Breadth of tick marks.
Tick_Mark_Width = 1;

// Relief height/depth of marks.
Mark_Relief = 0.2;

// Twist of split-lines relative to part, in degrees.
Split_Twist = 0.001;

// How far away from origin to nudge splits?
Split_Shove = 38.1;

// Width of dovetail neck
Dovetail_Neck = 20;

// Width of dovetail flare
Dovetail_Tail = 24;

// Protrusion of dovetail tab
Dovetail_Depth = 4;

use <gears.scad>
use <pie.scad>
use <dovetail.scad>

module hole(x, y, d)
{
  hole_infinity = Part_Thickness * 20;
  drop = hole_infinity / 2; // punch all the way through
  radius = d / 2;
  translate([x, y, drop])
    cylinder(hole_infinity * 2, r1=radius, r2=radius, center=true);
}

module pinhole(x, y, d)
{
  hole(x, y, Pinhole_Diameter);
}

module penhole(x, y, d)
{
  hole(x, y, Penhole_Diameter);
}

module ring(teeth, pinhole_count) {
  radius = (teeth * Tooth_Module / 2);
  difference() {
    union() {
      herringbone_ring_gear(Tooth_Module, teeth, Part_Thickness, Ring_Rind,
                            pressure_angle=20, helix_angle=30);
      // Top rim
      //LIPPS=1; // Retainer-lip thickness
      //difference() {
      //  r = radius + Ring_Rind + Tooth_Module;
      //  translate([0,0,Part_Thickness])
      //    cylinder(r1=r, r2=r, h=LIPPS);
      //  rh = radius-0.5;
      //  cylinder(r1=rh, r2=rh, h=Part_Thickness * 5);
      //}
      // Tooth ticks
      //tickstep = 8;
      //for (t = [0:tickstep:teeth-tickstep]) {
      //  rotate([0, 0, t * (360 / teeth)])
      //    translate([radius + Tooth_Module * 2, -Tick_Mark_Width/2, Part_Thickness + LIPPS])
      //      cube([Ring_Rind - Tooth_Module, Tick_Mark_Width, Mark_Relief]);        
      //}
    }
    // Pinholes
    r = radius + (Ring_Rind * 0.667);
    offset = 360 / pinhole_count / 2;
    for(p = [0:1:pinhole_count]) {
      theta = offset + p * (360 / pinhole_count);
      pinhole(r * cos(theta), r * sin(theta));
    }
  }
}

module pinion(teeth) {
  difference() {
    // Radius of outermost hole.
    radius = (teeth * Tooth_Module / 2) - Wheel_Rim;
    rstep = (radius - Wheel_Bore) / teeth;
    tstep = (360 / teeth) * 8;
    holes = floor((radius - Wheel_Bore) / Wheel_Hole_Step);
    union() {
      difference() {
        herringbone_gear (modul=Tooth_Module, tooth_number=teeth, width=Part_Thickness, bore=0,
        pressure_angle=20, helix_angle=30, optimized=false);
        // Knockouts on body of gear
        if (false) {
          // 1/3rd from each side
          translate([0, 0,  0.667 * Part_Thickness])
            cylinder(Part_Thickness, r=radius + Pinhole_Diameter/2, center=false);
          translate([0, 0, -0.667 * Part_Thickness])
            cylinder(Part_Thickness, r=radius + Pinhole_Diameter/2, center=false);
        }
        else {
          // 1/2 from top side
          translate([0, 0,  0.5 * Part_Thickness])
            cylinder(Part_Thickness, r=radius + Pinhole_Diameter/2, center=false);
        }
      }
      for (t = [0:1:holes]) {
        theta = t * tstep;
        r = radius - (t * Wheel_Hole_Step);
        rotate([0, 0, theta]) {
          translate([r, -Tick_Mark_Width/2, Part_Thickness/2]) {
            cube([radius - r + Wheel_Rim, Tick_Mark_Width, Mark_Relief]);
          }
        }
      }
    }
    // Pen holes
    for (h = [0:1:holes]) {
      theta = h * tstep;
      r = radius - (h * Wheel_Hole_Step);
      x = r * cos(theta);
      y = r * sin(theta);
      penhole(x, y);
      }
    // Done
  }
}

module spoked_pinion(teeth, spokes, holeskip = 1) {
  // Radius of outermost hole.
  radius = (teeth * Tooth_Module / 2) - Wheel_Rim;
  rstep = (radius - Wheel_Bore) / teeth;
  tstep = (360 / teeth) * 8;
  holes = floor((radius - Wheel_Bore) / Wheel_Hole_Step);
  difference() {
    herringbone_gear (modul=Tooth_Module, tooth_number=teeth, width=Part_Thickness, bore=0,
    pressure_angle=20, helix_angle=30, optimized=false);
    // Knockouts on body of gear
    if (false) {
      // 1/3rd from each side
      translate([0, 0,  0.667 * Part_Thickness])
        cylinder(Part_Thickness, r=radius + Pinhole_Diameter/2, center=false);
      translate([0, 0, -0.667 * Part_Thickness])
        cylinder(Part_Thickness, r=radius + Pinhole_Diameter/2, center=false);
    }
    else {
      // 1/2 from top side
      translate([0, 0,  0.5 * Part_Thickness])
        cylinder(Part_Thickness, r=radius + Pinhole_Diameter/2, center=false);
    }
    // Knock out pie wedges to create spokes
    spoke_sweep = 360 / spokes;
    for (s = [0:1:spokes]) {
      theta = s * spoke_sweep;
      x = Wheel_Bore * cos(theta + (spoke_sweep / 2));
      y = Wheel_Bore * sin(theta + (spoke_sweep / 2));
      translate([x, y, -500])
        // Radius was formerly 2*Wheel_Bore, but this leaves too much
	// material. Would be nicer if this was beveled to the
	// gear rim, instead of stairstepping.
        pie(radius - 1.1 * Wheel_Bore, spoke_sweep, 1000, theta);
    }
    // Pen holes - must fall on spokes
    hstep = (360 / spokes);
    for (h = [0:1:holes]) {
      theta = ((h * holeskip) + (holeskip > 1 ? 1 : 0)) * hstep;
      r = radius - (h * Wheel_Hole_Step);
      x = r * cos(theta);
      y = r * sin(theta);
      penhole(x, y);
    }
  }
}

module split_ring(teeth, splits) {
  split_sweep = 360 / splits;
  radius = (teeth * Tooth_Module / 2);
  doveX = radius + Ring_Rind - 3 * (Dovetail_Tail - Dovetail_Neck);
  echo("radius", radius);
  echo("doveX", doveX);
  // Repeat whole enchilada for each split
  for (split = [0:1:splits-1]) {
    split_theta = Split_Twist + (split * split_sweep);
    xshove = Split_Shove * cos(split_theta + (split_sweep / 2));
    yshove = Split_Shove * sin(split_theta + (split_sweep / 2));
    // Shove the split away from the X/Y origin
    translate([xshove, yshove, 0]) {
      // Intersect the ring with two halfspaces which create the split-sector
      difference() {
        intersection() {
          ring(teeth, splits);
          // Half-space starting at theta
          rotate([0, 0, split_theta])
            translate([-1000, 0, 0])
              cube([2000, 2000, 2000]);
          // Half-space ending at (theta + sweep)
          rotate([0, 0, 180 + split_theta + split_sweep])
            translate([-1000, 0, 0])
              cube([2000, 2000, 2000]);
        }
        // Negative dovetail knockouts
        rotate([0, 0, split_theta])
          translate([doveX, 0, 0])
            dovetail(neck=Dovetail_Neck, tail=Dovetail_Tail, depth=Dovetail_Depth, thickness=Part_Thickness, sense=false);
      }
      // Positive dovetail addons
      rotate([0, 0, split_theta + split_sweep])
        translate([doveX, 0, 0])
          dovetail(neck=Dovetail_Neck, tail=Dovetail_Tail, depth=Dovetail_Depth, thickness=Part_Thickness, sense=true);
    }
  }
}

module spoked_split_pinion(teeth, splits) {
  radius = (teeth * Tooth_Module / 2);
  spokes = 2 * splits;
  split_sweep = 360 / splits;
  // Repeat whole enchilada for each split
  for (split = [0:1:splits-1]) {
    split_theta = Split_Twist + (split * split_sweep);
    xshove = Split_Shove * cos(split_theta + (split_sweep / 2));
    yshove = Split_Shove * sin(split_theta + (split_sweep / 2));
    // Shove the split away from the X/Y origin
    translate([xshove, yshove, 0]) {
      // Intersect the pinion with two halfspaces which create the split-sector
      union() {
        difference() {
          // The pinion sector
          intersection() {
            spoked_pinion(teeth, spokes, 2);
            // Half-space starting at theta
            rotate([0, 0, split_theta])
              translate([-500, 0, 0])
                cube([1000, 1000, 1000]);
            // Half-space ending at (theta + sweep)
            rotate([0, 0, 180 + split_theta + split_sweep])
              translate([-500, 0, 0])
                cube([1000, 1000, 1000]);
          }
          // Negative dovetail knockouts
          rotate([0, 0, split_theta])
            for(dovex = [radius - Wheel_Rim - Dovetail_Tail:-2 * Dovetail_Tail:Dovetail_Tail])
              translate([dovex, 0, 0])
                dovetail(neck=Dovetail_Neck, tail=Dovetail_Tail, depth=Dovetail_Depth, thickness=Part_Thickness / 2, sense=false);
        }
        // Positive dovetail addons
        rotate([0, 0, split_theta + split_sweep])
          for(dovex = [radius - Wheel_Rim - Dovetail_Tail:-2 * Dovetail_Tail:Dovetail_Tail])
            translate([dovex, 0, 0])
              dovetail(neck=Dovetail_Neck, tail=Dovetail_Tail, depth=Dovetail_Depth, thickness=Part_Thickness / 2, sense=true);
      }
    }
  }
}

//spoked_split_pinion(66, 4, 8);
//spoked_split_pinion(78, 5, 10);
//spoked_split_pinion(102, 6, 12);
//split_ring(144, 12);

if (Part_Type == "Wheel") {
  if (Splits < 2) {
    pinion(Tooth_Count);
  }
  else {
    difference() {
      spoked_split_pinion(Tooth_Count, Splits);
    }
  }
}
else if (Part_Type == "Ring") {
  if (Splits < 2) {
    ring(Tooth_Count);
  }
  else {
    split_ring(Tooth_Count, Splits);
  }
}
else {
  echo("Unknown Part Type: ", Part_Type);
}