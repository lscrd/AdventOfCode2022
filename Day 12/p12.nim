const DefDist = 100_000   # Default distance (some high value).

type

  Place = object
    height: char    # Height.
    dist: int       # Distance from starting point.

  Position = tuple[r, c: int]
  HeightMap = seq[seq[Place]]

proc `[]`(hm: HeightMap; pos: Position): Place =
  ## Return the place at given position.
  hm[pos.r][pos.c]

proc `[]`(hm: var HeightMap; pos: Position): var Place =
  ## Return the place variable at given position.
  hm[pos.r][pos.c]

var heightMap: HeightMap
var startPos, endPos: Position

# Build map.
var row = -1
for line in lines("p12.data"):
  if line.len == 0: break
  inc row
  heightMap.add @[]
  for col, c in line:
    heightMap[row].add Place(height: c, dist: DefDist)
    if c == 'S':
      startPos = (row, col)
      heightMap[startPos].height = 'a'
    elif c == 'E':
      endPos = (row, col)
      heightMap[endPos].height = 'z'

# Keep a copy of the starting map for part 2.
let refMap = heightMap


iterator nextPos(hm: HeightMap; pos: Position): Position =
  ## Yield the positions next to given position.
  let currHeight = hm[pos].height
  if pos.r > 0:
    let place = hm[pos.r-1][pos.c]
    if place.height <= succ(currHeight):
      yield (pos.r-1, pos.c)
  if pos.r < hm.high:
    let place = hm[pos.r+1][pos.c]
    if place.height <= succ(currHeight):
      yield (pos.r+1, pos.c)
  if pos.c > 0:
    let place = hm[pos.r][pos.c-1]
    if place.height <= succ(currHeight):
      yield (pos.r, pos.c-1)
  if pos.c < hm[0].high:
    let place = hm[pos.r][pos.c+1]
    if place.height <= succ(currHeight):
      yield (pos.r, pos.c+1)


proc computeDist(hm: var HeightMap; currPos: Position) =
  ## Recursively compute the minimal distances from starting position.
  let dist = hm[currPos].dist + 1
  for pos in hm.nextPos(currPos):
    if dist < hm[pos].dist:
      hm[pos].dist = dist
      hm.computeDist(pos)


### Part 1 ###
heightMap[startPos].dist = 0      # Initialize distance for staring position.
heightMap.computeDist(startPos)

echo "Part 1: ", heightMap[endPos].dist


### Part 2 ###

# Build list of possible starting positions.
var startList: seq[Position]
for r, row in heightMap:
  for c, place in row:
    if place.height == 'a':
      startList.add (r, c)

# Find minimal number of steps (i.e. minimal distance).
var minSteps = DefDist
for startPos in startList:
  heightMap = refMap                # Restore initial state.
  heightMap[startPos].dist = 0      # Initialize distance for starting position.
  heightMap.computeDist(startPos)
  let steps = heightMap[endPos].dist
  if steps < minSteps:
    minSteps = steps

echo "Part 2: ", minSteps
