import std/[math, strutils]

type
  Map = seq[string]
  MoveKind {.pure.} = enum Move, TurnLeft, TurnRight
  Direction {.pure.} = enum Right, Down, Left, Up
  PathElem = tuple[kind: MoveKind;  dist: int]
  Position = tuple[row, col: int]

const DataFile = "p22.data"

proc `[]`(map: Map; pos: Position): char =
  ## Index map by position.
  map[pos.row][pos.col]

proc prev(dir: Direction): Direction =
  ## Return the previous direction in a circular way.
  if dir == Direction.low: Direction.high else: pred(dir)

proc next(dir: Direction): Direction =
  ## Return the next direction in a circular way.
  if dir == Direction.high: Direction.low else: succ(dir)

# Build the map and the path.
var map: Map
var path: seq[PathElem]
var readMap = true
var colCount = 0
for line in lines(DataFile):
  if line.len == 0:
    if readMap:
      # Empty line after map descrition. Make sure all rows have same length.
      for row in map.mitems:
        row.add repeat(" ", colCount - row.len)
      readMap = false
    continue
  if readMap:
    # Add a row to the map.
    map.add line
    if line.len > colCount: colCount = line.len
  else:
    # Process the path line.
    var dist = 0
    for c in line:
      if c.isDigit: dist = 10 * dist + ord(c) - ord('0')
      else:
        if dist != 0:
          path.add (Move, dist)   # Add pending move.
          dist = 0
        path.add if c == 'L': (TurnLeft, 0) else: (TurnRight, 0)
    if dist != 0:
      path.add (Move, dist)   # Add pending move.


### Part 1 ###

proc next(map: Map; pos: Position; dir: Direction): Position =
  ## Return next position in given direction.
  case dir
  of Right:
    result = (pos.row, pos.col + 1)
    if result.col == map[0].len: result.col = 0
  of Down:
    result = (pos.row + 1, pos.col)
    if result.row == map.len: result.row = 0
  of Left:
    result = (pos.row, pos.col - 1)
    if result.col == -1: result.col = map[0].high
  of Up:
    result = (pos.row - 1, pos.col)
    if result.row == -1: result.row = map.high

proc move(map: Map; pos: var Position; dir: var Direction; dist: int) =
  ## Move in given direction for the given distance.
  var dist = dist
  while dist > 0:
    var newPos = map.next(pos, dir)
    while map[newPos] == ' ':
      newPos = map.next(newPos, dir)
    let c = map[newPos]
    if c == '#': return
    pos = newPos
    dec dist

var position: Position = (0, map[0].find('.'))
var direction = Right

for item in path:
  case item.kind
  of Move: map.move(position, direction, item.dist)
  of TurnLeft: direction = prev(direction)
  of TurnRight: direction = next(direction)

echo "Part 1: ", 1000 * (position.row + 1) + 4 * (position.col + 1) + ord(direction)


### Part 2 ###

# A cube is described as an array of 6 faces. A face has a position on the map (the position
# of its top left tile) and a list of its four neighbor in each direction.
# A neighbor if described as a face with a rotation to apply when entering it.

type

  Rotation = 0..3   # 0: no rotation, 1: 90° clockwise, 2: 180° clockwise, 3: 270° clockwise.
  Neighbor = tuple[face: Face; rotation: Rotation]

  Face = ref object
    num: Natural
    pos: Position
    neighbors: array[Direction, Neighbor]
  Faces = array[1..6, Face]

  # Position on the cube.
  CubePosition = tuple[face: Face; pos: Position; dir: Direction]

# Value used when no neighbor has been assigned yet.
let Unassigned: Neighbor = (nil, Rotation(0))

proc rotated(dir: Direction; n: Rotation): Direction =
  ## Return the direction after applying the given rotation.
  Direction((ord(dir) + n) mod 4)

proc neighbors(dir: Direction): array[2, Direction] =
  # Return the neighbor directions of the given direction.
  case dir
  of Right, Left: [Down, Up]
  of Down, Up: [Right, Left]

# Find the side size.
var tileCount = 0.0   # Number of tiles.
for row in map:
  for c in row:
    if c != ' ': tileCount += 1
let SideSize = int(sqrt(tileCount / 6))

proc initFaces(map: Map): Faces =
  ## Initialize the faces of the cube.

  # Create faces and set right and left neighbors if possible.
  let maxRow = map.high
  let maxCol = map[0].high
  var num = 1
  var unassignedCount = 24    # Four directions for six faces.
  for irow in countup(0, maxRow, SideSize):
    var prev, first, last: Face = nil
    for icol in countup(0, maxCol, SideSize):
      if map[irow][icol] != ' ':
        let curr = Face(num: num, pos: (irow, icol),
                        neighbors: [Unassigned, Unassigned, Unassigned, Unassigned])
        result[num] = curr
        if icol == 0: first = curr
        elif icol == 3 * SideSize: last = curr
        if not prev.isNil:
          prev.neighbors[Right] = (curr, Rotation(0))
          curr.neighbors[Left] = (prev, Rotation(0))
          dec unassignedCount, 2
        prev = curr
        inc num

  # Set the down and up neighbors if possible.
  for currNum in 1..5:
    let curr = result[currNum]
    let colNum = curr.pos.col
    for nextNum in (currNum + 1)..6:
      let next = result[nextNum]
      if next.pos.col == colNum:
        if next.pos.row == curr.pos.row + SideSize:
          curr.neighbors[Down] = (next, Rotation(0))
          next.neighbors[Up] = (curr, Rotation(0))
          dec unassignedCount, 2
          break

  # Set the remaining neighbors.
  # For instance, starting from a face, going down then going left leads to a face
  # which is on the left of the starting face, provided there is no rotation.
  # But, of course, we need to take in account the rotations.
  block finalize:
    while true:
      for face1 in result:
        for dir1 in Right..Up:
          if face1.neighbors[dir1].face.isNil:
            # Try to set this neighbor of "face1".
            for dir2 in dir1.neighbors():
              let (face2, rot12) = face1.neighbors[dir2]
              if not face2.isNil:
                # Found a "face2". Try now to find "face3".
                let (face3, rot23) = face2.neighbors[dir1.rotated(rot12)]
                if not face3.isNil:
                  # Found "face3"". Compute the rotation.
                  let rot = Rotation (ord(dir2) - ord(dir1) + rot12 + rot23 + 4) mod 4
                  face1.neighbors[dir1] = (face3, rot)
                  dec unassignedCount
                  break
            if unassignedCount == 0: break finalize

proc next(map: Map; cubePos: CubePosition): CubePosition =
  ## Return the next position on the cube.
  let MaxRow = SideSize - 1
  let MaxCol = SideSize - 1
  var rotation: Rotation

  result = cubePos
  case cubePos.dir
  of Right:
    inc result.pos.col
    if result.pos.col == SideSize:
      (result.face, rotation) = result.face.neighbors[Right]
      result.dir = result.dir.rotated(rotation)
      case rotation
      of 0:
        result.pos.col = 0
      of 1:
        result.pos.row = 0
        result.pos.col = MaxRow - cubePos.pos.row
      of 2:
        result.pos.col = MaxCol
        result.pos.row = MaxRow - result.pos.row
      of 3:
        result.pos.row = MaxRow
        result.pos.col = cubePos.pos.row
  of Down:
    inc result.pos.row
    if result.pos.row == SideSize:
      (result.face, rotation) = result.face.neighbors[Down]
      result.dir = result.dir.rotated(rotation)
      case rotation
      of 0:
        result.pos.row = 0
      of 1:
        result.pos.row = cubePos.pos.col
        result.pos.col = MaxCol
      of 2:
        result.pos.row = MaxRow
        result.pos.col = MaxRow - result.pos.col
      of 3:
        result.pos.row = MaxRow - cubePos.pos.col
        result.pos.col = 0
  of Left:
    dec result.pos.col
    if result.pos.col == -1:
      (result.face, rotation) = result.face.neighbors[Left]
      result.dir = result.dir.rotated(rotation)
      case rotation
      of 0:
        result.pos.col = MaxCol
      of 1:
        result.pos.row = MaxRow
        result.pos.col = MaxCol - cubePos.pos.row
      of 2:
        result.pos.col = 0
        result.pos.row = MaxRow - result.pos.row
      of 3:
        result.pos.row = 0
        result.pos.col = cubePos.pos.row
  of Up:
    dec result.pos.row
    if result.pos.row == -1:
      (result.face, rotation) = result.face.neighbors[Up]
      result.dir = result.dir.rotated(rotation)
      case rotation
      of 0:
        result.pos.row = MaxRow
      of 1:
        result.pos.row = cubePos.pos.col
        result.pos.col = 0
      of 2:
        result.pos.row = 0
        result.pos.col = MaxRow - result.pos.col
      of 3:
        result.pos.row = MaxRow - cubePos.pos.col
        result.pos.col = MaxCol

proc move(map: Map; cubePos: var CubePosition; dist: int) =
  ## Move on the cube for the given distance.
  var dist = dist
  while dist > 0:
    var newPos = map.next(cubePos)
    var mapPos: Position = (newPos.face.pos.row + newPos.pos.row,
                            newPos.face.pos.col + newPos.pos.col)
    let c = map[mapPos]
    if c == '#': return
    cubePos = newPos
    dec dist

let faces = initFaces(map)
var cubePos: CubePosition = (faces[1], (0, 0), Right)

for item in path:
  case item.kind
  of Move: map.move(cubePos, item.dist)
  of TurnLeft: cubePos.dir = prev(cubePos.dir)
  of TurnRight: cubePos.dir = next(cubePos.dir)

let mapRow = cubePos.face.pos.row + cubePos.pos.row
let mapCol = cubePos.face.pos.col + cubePos.pos.col

echo "Part 2: ", 1000 * (mapRow + 1) + 4 * (mapCol + 1) + ord(cubePos.dir)
