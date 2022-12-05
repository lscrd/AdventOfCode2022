import std/strscans

## Representation of a range.
type Range = tuple[a, b: int]


### Part 1 ###

func contains(r1, r2: Range): bool =
  ## Return true if range "r1" contains range "r2".
  r1.a <= r2.a and r1.b >= r2.b

var count = 0
for line in lines("p04.data"):
  var r1, r2: Range
  if scanf(line, "$i-$i,$i-$i", r1.a, r1.b, r2.a, r2.b):
    if r1.contains(r2) or r2.contains(r1):
      inc count

echo "Part 1: ", count


### Part 2 ###

func overlap(r1, r2: Range): bool =
  ## Return true if ranges "r1" and "r2" overlap.
  r1.a <= r2.a and r1.b >= r2.a or r1.a >= r2.a and r1.a <= r2.b

count = 0
for line in lines("p04.data"):
  var r1, r2: Range
  if scanf(line, "$i-$i,$i-$i", r1.a, r1.b, r2.a, r2.b):
    if overlap(r1, r2):
      inc count

echo "Part 2: ", count
