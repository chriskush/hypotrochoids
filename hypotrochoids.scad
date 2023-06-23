// @copyright  Chris Kush 2019, 2020, 2022
// @file       hypotrochoids.scad
// @source     https://github.com/chriskush/hypotrochoids/blob/main/hypotrochoids.scad
// @license    http://creativecommons.org/licenses/LGPL/2.1/
// @license    http://creativecommons.org/licenses/by-sa/3.0//
// @brief      Mark arbitrary hypotrochoids on any flat, smooth medium.
// @see        https://www.instagram.com/silent.hemiola/

// Ring or wheel?
Part_Type = "Ring"; // ["Wheel", "Ring"]

// How many teeth?
Tooth_Count = 144;

// Split into how many parts?
Splits = 12;

// Tooth rise/fall above ideal circle.
Tooth_Module = 5.0; //[1:0.5:10]

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

Ring_Thing_Box_Width = 945.0;
Ring_Thing_Box_Height = 254.0;
// Dimensions of the imaginary box where Thing-bolts go.

// PROTO-series 144x5 rings were printed with 12 Splits, Twisted -0.02deg, with
// 90mm-long Things protruding from the (angular) center of the Ring segment.
// Making the Things 100mm long (to improve bracing and/or paper clearance)
// would exceeds the standard Prusa bed size. This creates a Ring Thing Box
// of 945x254mm. (To match this hole placement using the old center-and-length
// Things, a 210x3.5 ring requires 82.5mm-long Things.)
// - There are only two (2) types of ring segment, the type with a Thing and the
//   type without. (Each segment has exactly twelve (12) teeth.
//
// The NEO-series 140x5 ring uses 14 splits, and a twist of -13.10deg; this:
// - Ensures no tiny (poorly-printing) tooth-lets on the segment-to-
//   segment interfaces.
// - Ensures there are only three (3) types of ring pieces - two types of Thing-bearing
//   segments (called "A" and "B"), and plain (un-Thinged) segments. Pieces of
//   a given type are interchangeable.

// Thickness of parts (at gear teeth).
Part_Thickness = 10;

// Diameter of fixing-holes for ring parts (including things).
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

// Draw the print-bed platter under the first split-part?
Print_Bed_Preview = true;

// Max width of print bed for preview.
Print_Bed_X_Size = 250;

// Max depth of print bed for preview.
Print_Bed_Y_Size = 200;

use <gears.scad>
use <pie.scad>
use <dovetail.scad>

// Construct the four corners of the Thing bolthole bounding box.
Ring_Thing_Box_UL = [ -Ring_Thing_Box_Width / 2.0,  Ring_Thing_Box_Height / 2.0 ];
Ring_Thing_Box_UR = [  Ring_Thing_Box_Width / 2.0,  Ring_Thing_Box_Height / 2.0 ];
Ring_Thing_Box_LL = [ -Ring_Thing_Box_Width / 2.0, -Ring_Thing_Box_Height / 2.0 ];
Ring_Thing_Box_LR = [  Ring_Thing_Box_Width / 2.0, -Ring_Thing_Box_Height / 2.0 ];

// Find the four angles at which Things must be constructed. (Bias results
// from [-180..180] to [0...360])
Ring_Thing_Angle_UL = (atan2(Ring_Thing_Box_UL[0], Ring_Thing_Box_UL[1]) + 180.0) % 360.0;
Ring_Thing_Angle_UR = (atan2(Ring_Thing_Box_UR[0], Ring_Thing_Box_UR[1]) + 180.0) % 360.0;
Ring_Thing_Angle_LL = (atan2(Ring_Thing_Box_LL[0], Ring_Thing_Box_LL[1]) + 180.0) % 360.0;
Ring_Thing_Angle_LR = (atan2(Ring_Thing_Box_LR[0], Ring_Thing_Box_LR[1]) + 180.0) % 360.0;

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

module ring(teeth, pinhole_count, pinhole_angular_bias) {
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
      theta = pinhole_angular_bias + offset + p * (360 / pinhole_count);
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
  doveX = radius + Ring_Rind - 3.5 * (Dovetail_Tail - Dovetail_Neck);
  // NOTE:
  //  Some new information has recently come to light regarding
  //  the size of ring gears, man.
  //
  //  Note that the Things are placed at (radius + Ring_Rind).
  //  We were confused as to why this worked - shouldn't that
  //  place the butt end of the Thing tangent to the ring's
  //  outer circumference? Wouldn't you need to do
  //     (radius + Ring_Rind - Fudge_Factor)
  //  in order to ensure that the Thing was thoroughly connected
  //  to the Ring?
  //
  //  As it turns out, the way the gear library is coded, the basic
  //  "radius" computation (teeth * module / 2) yields the radius
  //  of the *pitch* circle - but the rim_width parameter (which
  //  we call Ring_Rind) is measured from the *root* circle.
  //
  //  (The pitch circle is the nominal gear size, midway-ish up the
  //   teeth, while the root circle corresponds to the tooth valleys.)
  //
  // This is why no fudge-factor is needed; it's present implicitly,
  // as the difference between the radii of the pitch circle (where
  // "radius" ends) and the root circle (where rim_width/Ring_Rind
  // begins).
  //
  // Going forward, we should make this fact explicit, to allow
  // better control of positioning Ring accessories, *especially*
  // the dovetails.
  //
  echo(str("INFO: Nominal ring radius is ",radius,"mm (",(radius/25.4),"in); diameter ",(2*radius),"mm (",((2*radius)/25.4),")in"));
  echo(str("INFO: Ring-holes at ",(radius + (Ring_Rind * 0.667)),"mm"));
  echo(str("INFO: Things at ",Ring_Thing_Angle_UL,"deg, ",Ring_Thing_Angle_UR,"deg, ",Ring_Thing_Angle_LL,"deg, and ",Ring_Thing_Angle_LR,"deg"));

  // Maintain compatibility with early prototypes
  if (Part_Type == "Ring" && Tooth_Count == 144 && Splits == 12
      && Tooth_Module == 5 && Part_Thickness == 10
      && Dovetail_Neck == 20 && Dovetail_Tail == 24 && Dovetail_Depth == 4) {
    // Before dovetails were auto-positioned, we used 382 for the
    // 144-tooth ring.
    doveX = echo(str("WARN: Overriding automatic dovetail position of ",doveX,"mm with 382mm for backward compatibility")) 382;
    if (Split_Twist != -0.02) {
      Split_Twist = echo(str("WARN: Overriding Split_Twist value of ",Split_Twist,"deg with -0.02deg for backward compatibility")) -0.02;
    }
  } // End of if - backward compatibility

  thing_radius = sqrt((Ring_Thing_Box_UR[0]^2) + (Ring_Thing_Box_UR[1]^2));
  thing_length = thing_radius - (radius + Ring_Rind);

  echo(str("INFO: Things radius ",thing_radius,"mm"));

  echo(str("INFO: Thingrithmetic:",Ring_Thing_Box_UR[0],"x, ",Ring_Thing_Box_UR[1],"y"));

  echo(str("INFO: Things length ",thing_length,"mm"));

  // Repeat whole enchilada for each split
  for (split = [0:1:splits-1]) {
    split_theta = Split_Twist + (split * split_sweep);
    xshove = Split_Shove * cos(split_theta + (split_sweep / 2));
    yshove = Split_Shove * sin(split_theta + (split_sweep / 2));
    // Determine whether this split gets a(ny) Thing(s).
    add_ul_thing_to_this_segment =
      (split_theta               <= Ring_Thing_Angle_UL &&
       split_theta + split_sweep >= Ring_Thing_Angle_UL);
    add_ur_thing_to_this_segment =
      (split_theta               <= Ring_Thing_Angle_UR &&
       split_theta + split_sweep >= Ring_Thing_Angle_UR);
    add_ll_thing_to_this_segment =
      (split_theta               <= Ring_Thing_Angle_LL &&
       split_theta + split_sweep >= Ring_Thing_Angle_LL);
    add_lr_thing_to_this_segment =
      (split_theta               <= Ring_Thing_Angle_LR &&
       split_theta + split_sweep >= Ring_Thing_Angle_LR);
    // Shove the split away from the X/Y origin
    translate([xshove, yshove, 0]) {
      // Intersect the ring with two halfspaces which create the split-sector
      difference() {
        intersection() {
          ring(teeth, splits, Split_Twist);
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

      // Add Thing for upper-left corner, if needed.
      if (add_ul_thing_to_this_segment) {
        rotate([0, 0, Ring_Thing_Angle_UL]) {
          translate([radius + Ring_Rind, -(Ring_Rind / 2), 0]) {
            difference() {
              union() {
                cube([thing_length, Ring_Rind, Part_Thickness]);
                translate([thing_length, Ring_Rind / 2, 0])
                  cylinder(h=Part_Thickness, d1=Ring_Rind, d2=Ring_Rind);
              } // End of union - rounded at the free end!
              pinhole(thing_length, Ring_Rind / 2);
            } // End of difference - thing from its pinhole
          } // End of translate - thing out to where the segment is
        } // End of rotate - thing to align with split segment
      } // End of if - make a thing for this part of the ring

      // Add Thing for upper-right corner, if needed.
      if (add_ur_thing_to_this_segment) {
        rotate([0, 0, Ring_Thing_Angle_UR]) {
          translate([radius + Ring_Rind, -(Ring_Rind / 2), 0]) {
            difference() {
              union() {
                cube([thing_length, Ring_Rind, Part_Thickness]);
                translate([thing_length, Ring_Rind / 2, 0])
                  cylinder(h=Part_Thickness, d1=Ring_Rind, d2=Ring_Rind);
              } // End of union - rounded at the free end!
              pinhole(thing_length, Ring_Rind / 2);
            } // End of difference - thing from its pinhole
          } // End of translate - thing out to where the segment is
        } // End of rotate - thing to align with split segment
      } // End of if - make a thing for this part of the ring

      // Add Thing for lower-left corner, if needed.
      if (add_ll_thing_to_this_segment) {
        rotate([0, 0, Ring_Thing_Angle_LL]) {
          translate([radius + Ring_Rind, -(Ring_Rind / 2), 0]) {
            difference() {
              union() {
                cube([thing_length, Ring_Rind, Part_Thickness]);
                translate([thing_length, Ring_Rind / 2, 0])
                  cylinder(h=Part_Thickness, d1=Ring_Rind, d2=Ring_Rind);
              } // End of union - rounded at the free end!
              pinhole(thing_length, Ring_Rind / 2);
            } // End of difference - thing from its pinhole
          } // End of translate - thing out to where the segment is
        } // End of rotate - thing to align with split segment
      } // End of if - make a thing for this part of the ring

      // Add Thing for lower-right corner, if needed.
      if (add_lr_thing_to_this_segment) {
        rotate([0, 0, Ring_Thing_Angle_LR]) {
          translate([radius + Ring_Rind, -(Ring_Rind / 2), 0]) {
            difference() {
              union() {
                cube([thing_length, Ring_Rind, Part_Thickness]);
                translate([thing_length, Ring_Rind / 2, 0])
                  cylinder(h=Part_Thickness, d1=Ring_Rind, d2=Ring_Rind);
              } // End of union - rounded at the free end!
              pinhole(thing_length, Ring_Rind / 2);
            } // End of difference - thing from its pinhole
          } // End of translate - thing out to where the segment is
        } // End of rotate - thing to align with split segment
      } // End of if - make a thing for this part of the ring

//      // Preview print bed?
//      if (Print_Bed_Preview && split == 0)
//        echo(str("doing thepreiveew"));
//        translate([Wheel_Bore * cos(split_sweep), 0, -10])
//          cube([Print_Bed_X_Size, Print_Bed_Y_Size, 5]);
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
      // Preview print bed?
      if (Print_Bed_Preview && split == 0)
        translate([Wheel_Bore * cos(split_sweep), 0, -10])
          cube([Print_Bed_X_Size, Print_Bed_Y_Size, 5]);
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
    ring(Tooth_Count, 0, 0);
  }
  else {
    split_ring(Tooth_Count, Splits);
  }
}
else {
  echo("ERROR: Unknown Part_Type: ", Part_Type);
}