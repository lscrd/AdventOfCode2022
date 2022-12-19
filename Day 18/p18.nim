import std/[strscans, tables]

type
  Position = tuple[x, y, z: int]
  Positions = seq[Position]

# Build list of cube positions.
var cubePos: Positions
for line in lines("p18.data"):
  var cube: Position
  if line.scanf("$i,$i,$i", cube.x, cube.y, cube.z):
    cubePos.add cube


### Part 1 ###

func dist(pos1, pos2: Position): int =
  ## Compute the Manhattan distance between two positions.
  abs(pos1.x - pos2.x) + abs(pos1.y - pos2.y) + abs(pos1.z - pos2.z)

var area = 0
for i1, c1 in cubePos:
  var count = 6
  for i2, c2 in cubePos:
    if i1 != i2 and dist(c1, c2) == 1:
      dec count
  inc area, count

echo "Part1: ", area


### Part 2 ###
type
  # Position states.
  State {.pure.} = enum Unknown, Free, Occupied
  States = Table[Position, State]   # Mapping from a position to a state.
  # Allowed ranges for coordinates.
  Range = Slice[int]
  Ranges = tuple[x, y, z: Range]

iterator neighbors(pos: Position; ranges: Ranges): Position =
  ## Yield the positions next to the given position
  ## with coordinates in allowed range.
  if pos.x - 1 >= ranges.x.a:
    yield (pos.x - 1, pos.y, pos.z)
  if pos.x + 1 <= ranges.x.b:
    yield (pos.x + 1, pos.y, pos.z)
  if pos.y - 1 >= ranges.y.a:
    yield (pos.x, pos.y - 1, pos.z)
  if pos.y + 1 <= ranges.y.b:
    yield (pos.x, pos.y + 1, pos.z)
  if pos.z - 1 >= ranges.z.a:
    yield (pos.x, pos.y, pos.z - 1)
  if pos.z + 1 <= ranges.z.b:
    yield (pos.x, pos.y, pos.z + 1)

proc initStates(cubePos: Positions; ranges: Ranges): States =
  ## Create the state table.
  for x in ranges.x:
    for y in ranges.y:
      for z in ranges.z:
        let pos: Position = (x, y, z)
        result[pos] = if pos in cubePos: Occupied
                      elif x in [ranges.x.a, ranges.x.b] or
                           y in [ranges.y.a, ranges.y.b] or
                           z in [ranges.z.a, ranges.z.b]: Free
                      else: Unknown

proc propagate(states: var States; ranges: Ranges) =
  ## Starting from current states, propagate the "Free" state to
  ## connected positions until no more change can be done.
  ## Remaining positions in state "Unknown" are not connected
  ## to the outside.
  var changed = true
  while changed:
    changed = false
    for pos, state in states.pairs:
      if state == Free:
        for neighbor in pos.neighbors(ranges):
          if states[neighbor] == Unknown:
            states[neighbor] = Free
            changed = true

# Compute the allowed ranges for coordinates.
const DefRange = 100 .. -100
var ranges: Ranges = (x: DefRange, y: DefRange, z: DefRange)
for pos in cubePos:
  if pos.x < ranges.x.a: ranges.x.a = pos.x
  elif pos.x > ranges.x.b: ranges.x.b = pos.x
  if pos.y < ranges.y.a: ranges.y.a = pos.y
  elif pos.y > ranges.y.b: ranges.y.b = pos.y
  if pos.z < ranges.z.a: ranges.z.a = pos.z
  elif pos.z > ranges.z.b: ranges.z.b = pos.z

# Build the state table.
var states = initStates(cubePos, ranges)
states.propagate(ranges)

# Compute the number of faces to remove from the area.
var faceCount = 0
for pos, state in states.pairs:
  if state == Unknown:
    for neighbor in pos.neighbors(ranges):
      if states[neighbor] == Occupied:
        inc faceCount

echo "Part2: ", area - faceCount
