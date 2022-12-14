import std/[sets, strutils]

type
  Position = tuple[x, y: int]
  PositionSet = HashSet[Position]  # Keep all non free positions.

proc expand(posSet: var PositionSet; ends: seq[Position]) =
  ## Expand a list of segment ends into a list of positions
  ## and add them to the given set of positions.
  var p1 = ends[0]
  for i in 1..ends.high:
    let p2 = ends[i]
    var (minx, miny) = p1
    var (maxx, maxy) = p2
    if minx > maxx: swap minx, maxx
    if miny > maxy: swap miny, maxy
    if minx == maxx:
      for y in miny..maxy:
        posSet.incl (minx, y)
    else:
      for x in minx..maxx:
        posSet.incl (x, miny)
    p1 = p2


# Build the initial list of non free positions.
var positions: PositionSet
var ymax = 0
for line in lines("p14.data"):
  if line.len == 0: continue
  let fields = line.split(" -> ")
  var ends: seq[Position]
  for field in fields:
    let coords = field.split(',')
    let x = parseInt(coords[0])
    let y = parseInt(coords[1])
    ends.add (x: x, y: y)
    if y > ymax: ymax = y
  positions.expand(ends)

# Keep a copy for part 2.
let posRef = positions


proc simulate(posSet: var PositionSet; ymax: int; withFloor: bool): int =
  ## Simulate sand falling with and without a floor.
  ## "ymax" is the maximum y coordinate value of initial positions in the set.

  # Limit for "y".
  let ylim = if withFloor: ymax + 2 else: ymax + 1

  while true:
    # Create a new unit of sand.
    var currPos: Position = (500, 0)

    while true:
      # Find next position, if any.
      var nextPos: Position =  (currPos.x, currPos.y + 1)
      if nextPos in posSet:
        nextPos = (currPos.x - 1, currPos.y + 1)
        if nextPos in posSet:
          nextPos = (currPos.x + 1, currPos.y + 1)
          if nextPos in posSet:
            # Unit is blocked and goes at rest.
            posSet.incl currPos
            inc result
            break

      # Check limit.
      if nextPos.y == ylim:
        if not withFloor: return    # Will go to infinity.
        # The unit rests on the floor.
        posSet.incl currPos
        inc result
        break

      # Move unit.
      currPos = nextPos

    # Terminate if current position is still at initial position.
    if currPos.y == 0: break

### Part 1 ###
echo "Part 1: ", positions.simulate(ymax, withFloor = false)

### Part 2 ###
positions = posRef
echo "Part 2: ", positions.simulate(ymax, withFloor = true)
