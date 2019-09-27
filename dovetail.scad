module dovetail(nose, tail, depth, thickness, sense) {
  // nose - narrow end of 'tail
  // tail - wide end of 'tail
  // depth - distance from nose to tail
  // thickness - thickness (in Z) of 'tail
  // sense - positive (male) or negative (female)
  //   'Positive tails get unioned
  //   'Negative tails get differenced
  linear_extrude(height = thickness) {
    translate([0, -depth * 0.05])
      polygon([ [-nose / 2, 0], [nose / 2, 0],
                [tail / 2, depth], [-tail / 2, depth] ]);
  }
}