// Ring or wheel?
Part_Type = "Wheel"; // ["Wheel", "Ring"]

// How many teeth?
Tooth_Count = 66;

// Split into how many parts?
Splits = 1;

// Tooth rise/fall above ideal circle.
Tooth_Module = 5;

// Radial increment for wheel pen-holes.
Wheel_Penhole_Step = 3.175;

// Number the penholes? (May require increasing OpenCSG "Turn off rendering at..." value!)
Wheel_Penhole_Numbers = true;

// Radius of unusable center area of wheels.
Wheel_Bore = 31.75;

// Amount of unusable outer part of wheels.
Wheel_Rim = Tooth_Module * 3;

// Width of spokes for split wheels
Wheel_Spoke_Width = 20;

// Breadth of ring segments.
Ring_Rind = 38.1;

// Length of ring extenders
Ring_Thing_Length = 150;

// Thickness of parts (at gear teeth).
Part_Thickness = 10;

// Diameter of fixing-holes for rings.
Pinhole_Diameter = 5;

// Diameter of pen-holes for wheels.
Penhole_Diameter = 8;

// Breadth of tick marks.
Tick_Mark_Width = 1;

// Relief height/depth of marks.
Mark_Relief = 0.2;

// Relief marks on bottom?
Mark_Bottom = true;

// Twist of split-lines relative to part, in degrees.
Split_Twist = -0.02;

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

module wheel(teeth) {
  difference() {
    // Radius of outermost hole.
    radius = (teeth * Tooth_Module / 2) - Wheel_Rim;
    rstep = (radius - Wheel_Bore) / teeth;
    tstep = (360 / teeth) * 8;
    holes = floor((radius - Wheel_Bore) / Wheel_Penhole_Step);
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
        r = radius - (t * Wheel_Penhole_Step);
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
      r = radius - (h * Wheel_Penhole_Step);
      x = r * cos(theta);
      y = r * sin(theta);
      penhole(x, y);
      }
    // Done
  }
}

module spoked_wheel(teeth, spokes, holeskip = true) {
  // Radius of outermost hole.
  radius = (teeth * Tooth_Module / 2) - Wheel_Rim;
  rstep = (radius - Wheel_Bore) / teeth;
  tstep = (360 / teeth) * 8;
  holes = floor((radius - Wheel_Bore - (Penhole_Diameter)) / Wheel_Penhole_Step);
  difference() {
    union() {
      difference() {
        // Gear
        herringbone_gear(modul=Tooth_Module, tooth_number=teeth, width=Part_Thickness, bore=2*radius - Part_Thickness,
                        pressure_angle=20, helix_angle=30, optimized=false);
        // Apply rim bevel
        translate([0, 0, Part_Thickness / 2])
          cylinder(h=Part_Thickness, r1=radius - Part_Thickness / 2, r2=radius + Part_Thickness / 2);
      }
      // Add spokes
      for (s = [0:1:spokes]) {
        rotate([0, 0, s * (360 / spokes)]) {
          // Translate by *0.333 (or something Dovetail_Depth-based) for non-hole spokes to even out dovetails
          spokeSlide = (holeskip && ((s % 2) == 0))
            ? (Wheel_Spoke_Width - Dovetail_Depth) / 2
            : (Wheel_Spoke_Width / 2); 
          translate([0, -spokeSlide, 0])
            cube([radius, Wheel_Spoke_Width, Part_Thickness / 2]);
        }
      }
      // Add hub
      cylinder(h=Part_Thickness / 2, r=Wheel_Bore + (Wheel_Spoke_Width / 2));
      } // End of union - gear ring, spokes & hub
    // (360 / Tooth_Count)
    toothTheta = 360 / Tooth_Count;
    // Pen holes - must fall on spokes
    for (h = [0:1:holes]) {
      // Map hole to spoke. Skip even-numbered spokes if requested, to
      // accomodate splitting. 
      s = holeskip ? (2 * h) + 1 : h;
      holeTheta = (s * (360 / spokes)) % 360;
      // Snap the angle to the nearest tooth, so penholes align with teeth.
      holeToothOffsetFractional = holeTheta / toothTheta;
      holeToothOffsetWholeLo = floor(holeToothOffsetFractional);
      holeToothOffsetWholeHi = ceil(holeToothOffsetFractional);
      holeThetaAdjusted = abs(holeToothOffsetFractional - holeToothOffsetWholeLo) <= abs(holeToothOffsetWholeHi - holeToothOffsetFractional)
        ? holeTheta - (toothTheta * (holeToothOffsetFractional - holeToothOffsetWholeLo))
        : holeTheta + (toothTheta * (holeToothOffsetWholeHi - holeToothOffsetFractional));
      // Plot the hole
      r = radius - (h * Wheel_Penhole_Step);
      x = r * cos(holeThetaAdjusted);
      y = r * sin(holeThetaAdjusted);
      penhole(x, y);
      // Annotate
      if (Wheel_Penhole_Numbers && (r >= (Wheel_Bore + 2 * Penhole_Diameter))) {
        zOffset = Mark_Bottom ? -1 : (Part_Thickness / 2 - Mark_Relief);
        xScale = Mark_Bottom ? -1 : 1;
        textR = (r > (Wheel_Bore + 2 * Penhole_Diameter)) ? r - Penhole_Diameter * 0.35 : r + Penhole_Diameter * 0.35;
        textAlign = (r > (Wheel_Bore + 2 * Penhole_Diameter)) ? "left" : "right";
        //textDrop = (r > (Wheel_Bore + 2 * Penhole_Diameter)) ? -Penhole_Diameter * 0.75 : Penhole_Diameter * 0.75;
        textDrop = abs(holeToothOffsetFractional - holeToothOffsetWholeLo) <= abs(holeToothOffsetWholeHi - holeToothOffsetFractional)
          ? Penhole_Diameter * 0.9 : -Penhole_Diameter * 0.9;
        textDrop2 = (r < (Wheel_Bore + 2 * Penhole_Diameter)) ? -textDrop : textDrop;
        textAlignV = textDrop2 <= 0 ? "bottom" : "top";
        rotate(holeThetaAdjusted)
          translate([textR, textDrop2, 0])
            translate([0, 0, zOffset])
              linear_extrude(height=(Mark_Relief + 1))
                scale([xScale, 1, 1])
                  text(text=str(h), size=(Penhole_Diameter / 2), font="Cascadia Code:Bold",
                       halign=textAlign, valign=textAlignV);
      }
    }
    // Delete any useless middle (how much?)
    translate([0, 0, -Part_Thickness / 2])
      cylinder(h=Part_Thickness * 2, r=Wheel_Bore);
  }
}

module split_ring(teeth, splits) {
  split_sweep = 360 / splits;
  radius = (teeth * Tooth_Module / 2);
  doveX = radius + Ring_Rind - 3 * (Dovetail_Tail - Dovetail_Neck);

  // Maintain compatibility with early prototypes
  if (Tooth_Count == 144 && Tooth_Module == 5 && Part_Thickness == 10
      && Dovetail_Neck == 20 && Dovetail_Tail == 24 && Dovetail_Depth == 4
      && Splits == 12 && Split_Twist == -0.02) {
    // Before dovetails were auto-positioned, we used 382 for the
    // 144-tooth ring.
    echo("Info: Overriding automatic dovetail position of ",doveX," with 382 for backward compatibility");
    doveX = 382;
  } // End of if - backward compatibility

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
      // "Things"
      if (Ring_Thing_Length > 0 && splits > 0 && ((split % 2) == 1)) {
        rotate([0, 0, split_theta + split_sweep / 2]) {
          translate([radius + Ring_Rind, -(Ring_Rind / 2), 0]) {
            difference() {
              union() {
                cube([Ring_Thing_Length, Ring_Rind, Part_Thickness]);
                translate([Ring_Thing_Length, Ring_Rind / 2, 0])
                  cylinder(h=Part_Thickness, d1=Ring_Rind, d2=Ring_Rind);
              } // End of union - rounded at the free end!
              pinhole(Ring_Thing_Length, Ring_Rind / 2);
            } // End of difference - thing from its pinhole
          } // End of translate - thing out to where the segment is
        } // End of rotate - thing to align with split segment
      } // End of if - make a thing for this part of the ring
    } // End of translate - this split away from the origin
  } // End of for - each split
} // End of module - split_ring

module spoked_split_wheel(teeth, splits) {
  radius = (teeth * Tooth_Module / 2);
  //spokes = 2 * splits; // Note: for the 40-tooth wheel (18 loops @ 144 ringteeth
           // replace this with "max(2 * splits, 8);" to ensure a certain
  spokes = max(2 * splits, 8);
		       // spoke count. Note also that a 40-tooth wheel, even with no
		       // splits, can have a bore-out of zero (0) - maybe it's time
		       // to implement a "max-radius" (where "radius" is not the
		       // radius of the wheel, but the distance from the bore-hole
		       // to the edge - the "pie depth" or "wedge height" or
		       // something. Ultimately, you'd want "max build plate x/y"
		       // params, and have the code fit the pie-slice to that
		       // max-rect - and also, generate inner ring pieces.
		       //
		       // And then, the next enhancement is to split not just by
		       // sectors, but by radii as well. Then the inner arcs of
		       // large pie-wedges would have dovetails to mate with the
		       // circumference of inner pieces - maybe just a ring, but
		       // very large gears would require (for example) an outer
		       // series of 8 sectors, an intermediate set of 4, and ten
		       // a central disc.
  split_sweep = 360 / splits;
  // Repeat whole enchilada for each split
  for (split = [0:1:splits-1]) {
    split_theta = Split_Twist + (split * split_sweep);
    xshove = Split_Shove * cos(split_theta + (split_sweep / 2));
    yshove = Split_Shove * sin(split_theta + (split_sweep / 2));
    // Shove the split away from the X/Y origin
    translate([xshove, yshove, 0]) {
      // Intersect the wheel with two halfspaces which create the split-sector
      union() {
        difference() {
          // The wheel sector
          intersection() {
            spoked_wheel(teeth, spokes, true);
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
            for(dovex = [radius - Wheel_Rim - Dovetail_Tail:-2 * Dovetail_Tail:Wheel_Bore + Dovetail_Tail])
              translate([dovex, 0, 0])
                dovetail(neck=Dovetail_Neck, tail=Dovetail_Tail, depth=Dovetail_Depth, thickness=Part_Thickness / 2, sense=false);
        }
        // Positive dovetail addons
        rotate([0, 0, split_theta + split_sweep])
          for(dovex = [radius - Wheel_Rim - Dovetail_Tail:-2 * Dovetail_Tail:Wheel_Bore + Dovetail_Tail])
            translate([dovex, 0, 0])
              dovetail(neck=Dovetail_Neck, tail=Dovetail_Tail, depth=Dovetail_Depth, thickness=Part_Thickness / 2, sense=true);
      }
    }
  }
}

if (Part_Type == "Wheel") {
  if (Splits < 2) {
    wheel(Tooth_Count);
  }
  else {
    difference() {
      spoked_split_wheel(Tooth_Count, Splits);
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
  echo("ERROR: Unknown Part_Type: ", Part_Type);
}