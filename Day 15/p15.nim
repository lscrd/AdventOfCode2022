import std/strscans

type
  Position = tuple[x, y: int]
  Couples = seq[tuple[sensor, beacon: Position]]
  Range = tuple[a, b: int]
  Ranges = seq[Range]

const EmptyRange: Range = (0, 1)

func distance(a, b: Position): int =
  ## Return the Manhattan distance between two positions.
  abs(a.x - b.x) + abs(a.y - b.y)

func closerRange(start: Position; dist: Natural; y: int): Range =
  ## Return the range of x coordinates of positions at y coordinate "y"
  ## whose distance from "start" is less than or equal to "dist".
  let dy = abs(start.y - y)
  let dx = dist - dy
  result = if dx > 0: (start.x - dx, start.x + dx) else: EmptyRange

func merge(ranges: var Ranges) =
  ## Update a list of ranges, merging them when possible.
  var changed = true
  while changed:
    block round:
      for i in 0..<ranges.high:
        let (a1, b1) = ranges[i]
        for j in (i + 1)..ranges.high:
          let (a2, b2) = ranges[j]
          if a1 <= a2:
            if b1 >= b2:
              # [a1, b1] contains [a2, b2].
              ranges.del(j)
              break round
            if b1 >= a2:
              # Union of [a1, b1] and [a2, b2] is [a1, b2].
              ranges[i].b = b2
              ranges.del(j)
              break round
          else:
            if b1 <= b2:
              # [a2, b2] contains [a1, b1].
              ranges.del(i)
              break round
            if a1 <= b2:
              # Union of [a1, b1] and [a2, b2] is [a2, b1].
              ranges[j].b = b1
              ranges.del(i)
              break round
      # No change done.
      changed = false

func remove(ranges: var Ranges; x: int) =
  ## Remove a value from a list of ranges.
  ## Ranges must have been merged so that the value belongs to at most one range.
  for i in 0..ranges.high:
    let r = ranges[i]
    if x in r.a..r.b:
      if r.a == r.b:
        # Single value. Delete range.
        ranges.del(i)
      elif x == r.a:
        # Adjust low bound.
        inc ranges[i].a
      elif x == r.b:
        # Adjust high bound.
        dec ranges[i].b
      else:
        # Split range in two ranges.
        let b = ranges[i].b
        ranges[i].b = x - 1
        ranges.add (x + 1, b)
      return


func exclusionRange(couples: Couples; yVal: int; removeBeacons: bool): Ranges =
  ## Build the list of ranges describing the positions where no beacon can be present.
  ## If "removeBeacons" is true, we remove the detected beacons x coordinates (part 1).
  ## If it is false, we keep these coordinates (part 2).
  var xBeacons: seq[int]    # List of x coordinates of beacons at y coordinate "yVal".
  for (sensor, beacon) in couples:
    if beacon.y == yVal: xBeacons.add beacon.x
    let dist = distance(sensor, beacon)
    let r = sensor.closerRange(dist, yVal)
    if r != EmptyRange: result.add r
  result.merge()
  if removeBeacons:
    for x in xBeacons:
      result.remove(x)


# Build a list of (sensor, closest beacon)
var couples: seq[tuple[sensor, beacon: Position]]
for line in lines("p15.data"):
  var xs, ys, xb, yb: int
  if line.scanf("Sensor at x=$i, y=$i: closest beacon is at x=$i, y=$i", xs, ys, xb, yb):
    couples.add ((xs, ys), (xb, yb))


### Part 1 ###

const YVal = 2_000_000
var count = 0
let noBeacons = couples.exclusionRange(YVal, true)
for r in noBeacons:
  inc count, r.b - r.a + 1
echo "Part 1: ", count


### Part 2 ###

func `-`(r: Range; ranges: Ranges): Range =
  ## Return the range of values in "r" and not in any range.
  ## Used to find the possible positions of a beacon.
  result = r
  for (a, b) in ranges:
    if a <= result.a:
      if b >= result.b:
        # [result.a, result.b] is contained in [a, b].
        return EmptyRange
      if b > result.a:
        # [result.a, result.b] - [a, b] = [b + 1, result.b].
        result.a = b + 1
    elif a <= r.b:
      # [result.a, result.b] - [a, b] = [result.a, a - 1]
      result.b = a - 1

const YMax = 4_000_000
for y in countdown(YMax, 0):  # Faster in reverse order.
  let result = (0, YMax) - couples.exclusionRange(y, false)
  if result != EmptyRange:
    echo "Part 2: ", result.a * 4_000_000 + y
    break
