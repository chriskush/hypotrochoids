# Silent Hemiola

This repository contains OpenSCAD source code and ancillary supporting the
construction of ring & pinion gears which are customized to permit drawing
[hypotrochoids](https://en.wikipedia.org/wiki/Hypotrochoid) upon an underlying medium.

The appearance & petal count of the resulting curves depends on the relative
numbers of gear teeth in the ring & pinion.

## Contents

File|Description
-|-
`hypotrochoids.scad`|OpenSCAD source for rings and pinions.
`hypotrochoids.json`|Presets for the above.
`gears.scad`|**Old** copy of Dr. Jörg Janssen's DIN gear library, which has been updated and maintained as [chrisspen/gears](https://github.com/chrisspen/gears/).
`pie.scad`|`pie` module from the [dotscad](https://github.com/dotscad/dotscad) project.
`Teeth.xlsx`|Spreadsheet of petal counts.

## Functional Manual

This section explains how to use the parts created by this library to draw
[hypotrochoids](https://en.wikipedia.org/wiki/Hypotrochoid) [artworks](https://www.instagram.com/silent.hemiola/).

Equipment terminology:

Term|Meaning
-|-
Board|Rigid surface with four (4) bolt holes to support the ring.
Ring|The large ring-shaped gear, with teeth on the inside, and four "things" that mount it to the board.
Pinion|The small spoked gear wheel. The spokes have 8mm diameter holes for pens.

Equipment notes:

- When oriented properly, the totally-flat side of the pinion (with the
  hole numbers marked) should face **up**; the spokes should be "floating"
  above the medium. This ensures the pen-hole numbers are visible, and reduces
  dragging friction on the medium.

- Prefer to use quick-drying markers & pens. Paint markers or other gloppy,
  slow-drying markers will get smeared around by the pinion as it travels.

Flower-drawing technique:

- Take a deep breath before beginning a new flower. You should attempt to start
  & finish a single flower in one continuous pass. If you stop, it's difficult
  to start up again with introducing visual hiccups, like small steps in the
  line, or an ink bloom where the marker paused in its travel.

- You will need to use both hands - one holds the pen, and the other helps keep
  the pinion gear teeth meshed against the ring as it rolls.

- It's okay if the pen-hole in the pinion is too large for the marker tip; the
  marker will just naturally orbit around the hole as you draw. (Don't try to
  think about this, or "help" it, or counteract it.)

- The pen-holes in the pinion are aligned with the pinion's gear teeth; this
  way, all the flowers produced by all the pinions can be made to line up
  precisely. (The spokes are _not_ aligned with anything; this means that on
  some pinions, the pen-holes look crooked, relative to the spoke.)

- After you line up the pinion, **roll it backward about a half-turn**; then insert
  your marker and begin drawing. It is more difficult to start the pinion
  rolling when the pen is very near the ring; by backing the pinion up
  first, you can start rolling smoothly, and carry that motion into the
  turnaround point, where the pen slows down and reverses direction as it
  approaches the ring.

## Operational Manual

How to design & print the parts.

## Design conventions.

## Design considerations

- Twist
- Bore

## Rendering & Slicing

- Boost limits in SCAD for big rings.
- Adaptive layers, .3mm layers
- Tweaking join tabs.

## Printing

- Bed level critical - big flat parts

## Assembly

Be gentle - line up the parts square, and push down on a big sturdy flat work
table. You will feel the layer lines on the part edges as distinct "clicks", as
the parts join.

When assembling the pie-wedges of pinions, it is better to get *all*
the tabs-and-slot joints started. 

## Attribution

This work is based upon:

- [Dr. Jörg Janssen's `gears.scad` library](https://www.thingiverse.com/thing:1604369)
and its adopters, maintainers, and contributors at [chrisspen/gears](https://github.com/chrisspen/gears/)

- [`pie.scad`](https://github.com/dotscad/dotscad/blob/master/pie.scad) from [dotscad](https://github.com/dotscad/dotscad).
