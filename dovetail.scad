module dovetail(neck, tail, depth, thickness, sense) {
  // neck - narrow end of 'tail
  // tail - wide end of 'tail
  // depth - distance from neck to tail
  // thickness - thickness (in Z) of 'tail
  // sense - positive (male) or negative (female)
  //   'Positive tails get unioned
  //   'Negative tails get differenced
  offset = depth / 4;
  thickener = sense ? 0 : thickness * 0.04;
  neck_sink = offset; //depth * 0.05;
  union() {
    neck_m = neck - offset * 2;
    neck_f = neck + offset * 2;
    tail_m = tail - offset * 2;
    tail_f = tail + offset * 2;
    translate([0, neck_sink, -thickener / 2])
      linear_extrude(height = thickness + thickener)
        offset(r=offset)
          polygon([ [tail_m / 2, depth], [-tail_m / 2, depth],
                    [-neck_m / 2, 0], [neck_m / 2, 0] ]);
    translate([0, neck_sink, -thickener / 2])
      linear_extrude(height = thickness + thickener)
        offset(r=-offset)
          polygon([ [tail_f / 2, depth], [-tail_f / 2, depth],
                    [-neck_f / 2, 0],
                    [-tail_f / 2, 0],
                    [-tail_f / 2, -depth],
                    [ tail_f / 2, -depth],
                    [ tail_f / 2, 0],
                    [ neck_f / 2, 0],
                    ]);
  }
}

dovetail_example();

$fs = 0.5;

module dovetail_example() {
  thickness=5;
  // Yang
  translate([-20, -10]) {
    union() {
      cube([40, 5, thickness]);
      translate([20, 5])
        dovetail(neck=20, tail=24, depth=4, thickness=thickness, sense=true);
    }
  }
  // Yin
  translate([-20, 4]) {
    difference() {
      cube([40, 15, thickness]);
      translate([20, 0])
        dovetail(neck=20, tail=24, depth=4, thickness=thickness, sense=false);
    }
  }
}
