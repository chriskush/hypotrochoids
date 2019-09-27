include <gears.scad>
include <pie.scad>
include <dovetail.scad>

module hole(x, y, d)
{
  hole_infinity = THICCNESS * 20;
  drop = hole_infinity / 2; // punch all the way through
  radius = d / 2;
  translate([x, y, drop])
    cylinder(hole_infinity * 2, r1=radius, r2=radius, center=true);
}

module pinhole(x, y, d)
{
  hole(x, y, PINHOLE_DIAMETER);
}

module penhole(x, y, d)
{
  hole(x, y, PENHOLE_DIAMETER);
}

// herringbone_ring_gear(2, 105, 5, 10, 20, 0);


// rack(modul=1, length=30, height=5, width=5, pressure_angle=20, helix_angle=20);

//spur_gear (modul=1, tooth_number=30, width=5, bore=4, pressure_angle=20, helix_angle=20, optimized=true);

//ring(96);

module ring(teeth) {
  radius = (teeth * TOOTH_MODUL / 2);
  echo(radius);
  difference() {
    union() {
      herringbone_ring_gear(TOOTH_MODUL, teeth, THICCNESS, RIND,
                            pressure_angle=20, helix_angle=30);
      // Top rim
      //difference() {
      //  r = radius + RIND + TOOTH_MODUL;
      //  translate([0,0,THICCNESS])
      //    cylinder(r1=r, r2=r, h=LIPPS);
      //  rh = radius-0.5;
      //  cylinder(r1=rh, r2=rh, h=THICCNESS * 5);
      //}
      // Tooth ticks
      //tickstep = 8;
      //for (t = [0:tickstep:teeth-tickstep]) {
      //  rotate([0, 0, t * (360 / teeth)])
      //    translate([radius + TOOTH_MODUL * 2, -TICKWIDTH/2, THICCNESS + LIPPS])
      //      cube([RIND - TOOTH_MODUL, TICKWIDTH, TICKRELIEF]);        
      //}
    }
    // Pinholes
    r = radius + (RIND * 0.667);
    offset = 360 / PINCOUNT / 2;
    for(p = [0:1:PINCOUNT]) {
      theta = offset + p * (360 / PINCOUNT);
      pinhole(r * cos(theta), r * sin(theta));
    }
  }
}

module pinion(teeth) {
  difference() {
    // Radius of outermost hole.
    radius = (teeth * TOOTH_MODUL / 2) - RIM;
    echo(radius);
    rstep = (radius - BORE) / teeth;
    tstep = (360 / teeth) * 8;
    holes = floor((radius - BORE) / HOLESTEP);
    union() {
      difference() {
        herringbone_gear (modul=TOOTH_MODUL, tooth_number=teeth, width=THICCNESS, bore=0,
        pressure_angle=20, helix_angle=30, optimized=false);
        // Knockouts on body of gear
        if (false) {
          // 1/3rd from each side
          translate([0, 0,  0.667 * THICCNESS])
            cylinder(THICCNESS, r=radius + PINHOLE_DIAMETER/2, center=false);
          translate([0, 0, -0.667 * THICCNESS])
            cylinder(THICCNESS, r=radius + PINHOLE_DIAMETER/2, center=false);
        }
        else {
          // 1/2 from top side
          translate([0, 0,  0.5 * THICCNESS])
            cylinder(THICCNESS, r=radius + PINHOLE_DIAMETER/2, center=false);
        }
      }
      for (t = [0:1:holes]) {
        theta = t * tstep;
        r = radius - (t * HOLESTEP);
        rotate([0, 0, theta]) {
          translate([r, -TICKWIDTH/2, THICCNESS/2]) {
            cube([radius - r + RIM, TICKWIDTH, TICKRELIEF]);
          }
        }
      }
    }
    // Pen holes
    for (h = [0:1:holes]) {
      theta = h * tstep;
      r = radius - (h * HOLESTEP);
      x = r * cos(theta);
      y = r * sin(theta);
      penhole(x, y);
      }
    // Done
  }
}

module spoked_pinion(teeth, spokes, holeskip = 1) {
  // Radius of outermost hole.
  radius = (teeth * TOOTH_MODUL / 2) - RIM;
  echo(radius);
  rstep = (radius - BORE) / teeth;
  tstep = (360 / teeth) * 8;
  holes = floor((radius - BORE) / HOLESTEP);
  difference() {
    herringbone_gear (modul=TOOTH_MODUL, tooth_number=teeth, width=THICCNESS, bore=0,
    pressure_angle=20, helix_angle=30, optimized=false);
    // Knockouts on body of gear
    if (false) {
      // 1/3rd from each side
      translate([0, 0,  0.667 * THICCNESS])
        cylinder(THICCNESS, r=radius + PINHOLE_DIAMETER/2, center=false);
      translate([0, 0, -0.667 * THICCNESS])
        cylinder(THICCNESS, r=radius + PINHOLE_DIAMETER/2, center=false);
    }
    else {
      // 1/2 from top side
      translate([0, 0,  0.5 * THICCNESS])
        cylinder(THICCNESS, r=radius + PINHOLE_DIAMETER/2, center=false);
    }
    // Knock out pie wedges to create spokes
    spoke_sweep = 360 / spokes;
    for (s = [0:1:spokes]) {
      theta = s * spoke_sweep;
      x = BORE * cos(theta + (spoke_sweep / 2));
      y = BORE * sin(theta + (spoke_sweep / 2));
      translate([x, y, -500])
        pie(radius - 2 * BORE, spoke_sweep, 1000, theta);
    }
    // Pen holes - must fall on spokes
    hstep = (360 / spokes);
    for (h = [0:1:holes]) {
      theta = ((h * holeskip) + (holeskip > 1 ? 1 : 0)) * hstep;
      r = radius - (h * HOLESTEP);
      x = r * cos(theta);
      y = r * sin(theta);
      penhole(x, y);
    }
  }
}

module spoked_split_pinion(teeth, splits, spokes) {
  split_shove = 14.14;
  split_sweep = 360 / splits;
  // Repeat whole enchilada for each split
  for (split = [0:1:splits-1]) {
    split_theta = split * split_sweep;
    xshove = split_shove * cos(split_theta + (split_sweep / 2));
    yshove = split_shove * sin(split_theta + (split_sweep / 2));
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
            for(dovex = [20, 60, 100, 140])
              translate([dovex, 0, 0])
                dovetail(nose=20, tail=24, depth=4, thickness=THICCNESS/2, sense=false);
        }
        // Positive dovetail addons
        rotate([0, 0, split_theta + split_sweep])
          for(dovex = [20, 60, 100, 140])
            translate([dovex, 0, 0])
              dovetail(nose=20, tail=24, depth=4, thickness=THICCNESS/2, sense=true);
      }
    }
  }
}

//rack_and_pinion (modul=1, rack_length=50, gear_teeth=30, rack_height=4, gear_bore=4, width=5, pressure_angle=20, helix_angle=0, together_built=true, optimized=true);

//ring_gear (modul=1, tooth_number=30, width=5, rim_width=3, pressure_angle=20, helix_angle=20);

//  herringbone_ring_gear (modul=1, tooth_number=72, width=THICCNESS, rim_width=3, pressure_angle=25, helix_angle=20);



//planetary_gear(modul=1, sun_teeth=16, planet_teeth=9, number_planets=5, width=5, rim_width=3, bore=4, pressure_angle=20, helix_angle=30, together_built=true, optimized=true);

//bevel_gear(modul=1, tooth_number=30,  partial_cone_angle=45, tooth_width=5, bore=4, pressure_angle=20, helix_angle=20);

// bevel_herringbone_gear(modul=1, tooth_number=30, partial_cone_angle=45, tooth_width=5, bore=4, pressure_angle=20, helix_angle=30);

// bevel_gear_pair(modul=1, gear_teeth=30, pinion_teeth=11, axis_angle=100, tooth_width=5, bore=4, pressure_angle = 20, helix_angle=20, together_built=true);

// bevel_herringbone_gear_pair(modul=1, gear_teeth=30, pinion_teeth=11, axis_angle=100, tooth_width=5, bore=4, pressure_angle = 20, helix_angle=30, together_built=true);

// worm(modul=1, thread_starts=2, length=15, bore=4, pressure_angle=20, lead_angle=10, together_built=true);

// worm_gear(modul=1, tooth_number=30, thread_starts=2, width=8, length=20, worm_bore=4, gear_bore=4, pressure_angle=20, lead_angle=10, optimized=1, together_built=1, show_spur=1, show_worm=1);
