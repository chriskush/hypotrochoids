module dovetail(nose, tail, depth, thickness, sense) {
  // nose - narrow end of 'tail
  // tail - wide end of 'tail
  // depth - distance from nose to tail
  // thickness - thickness (in Z) of 'tail
  // sense - positive (male) or negative (female)
  //   'Positive tails get unioned
  //   'Negative tails get differenced
  thickener = sense ? 0 : thickness * 0.04;
  nose_sink = depth * 0.05; 
  translate([0, -nose_sink, -thickener / 2])
    linear_extrude(height = thickness + thickener)
      polygon([ [-nose / 2, 0], [nose / 2, 0],
                [tail / 2, depth], [-tail / 2, depth] ]);
}

dovetail_example();
module dovetail_example() {
  thickness=3.30;
  // Yin
  translate([-20, -10]) {
    union() {
      cube([40, 5, thickness]);
      translate([20, 5])
        dovetail(nose=20, tail=24, depth=4, thickness=thickness, sense=true);
    }
  }
  // Yang
  translate([-20, 4]) {
    difference() {
      cube([40, 15, thickness]);
      translate([20, 0])
        dovetail(nose=20, tail=24, depth=4, thickness=thickness, sense=false);
    }
  }
}
