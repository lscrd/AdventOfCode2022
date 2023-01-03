import std/[sets, tables]

# We represent the blizzards as a table to map positions to sequences of directions.
# This allows to quickly check if a position is free.

type
  Position = tuple[row, col: int]
  Direction {.pure.} = enum North, East, South, West
  Blizzards = TableRef[Position, seq[Direction]]

const Increments = [North: (-1, 0), East: (0, 1), South: (1, 0), West: (0, -1)]

proc `+`(pos, incr: Position): Position =
  ## Add an increment to a position.
  (pos.row + incr.row, pos.col + incr.col)

# Build the blizzards representation.
var blizzards = new(Blizzards)
var row = -1
var startPos, endPos: Position  # Starting and ending positions.
var maxRow, maxCol: int         # Maximum row and column numbers (starting from 0).
for line in lines("p24.data"):
  if line.len == 0: break
  inc row
  maxRow = row
  maxCol = line.high
  for col, ch in line:
    let pos = (row, col)
    case ch
    of '^':
      blizzards.mgetOrPut(pos, @[]).add North
    of '>':
      blizzards.mgetOrPut(pos, @[]).add East
    of 'v':
      blizzards.mgetOrPut(pos, @[]).add South
    of '<':
      blizzards.mgetOrPut(pos, @[]).add West
    of '.':
      if row == 0: startPos = (0, col)
      else: endPos = (row, col)
    else:
      discard

proc update(blizzards: var Blizzards) =
  ## Update the positions of blizzards.
  var next = new(Blizzards)   # Allocate new table of blizzards.
  for pos, dirs in blizzards.pairs:
    for dir in dirs:
      var newPos = pos + Increments[dir]
      # Check limits.
      if newPos.row == 0: newPos.row = maxRow - 1
      elif newPos.row == maxRow: newPos.row = 1
      elif newPos.col == 0: newPos.col = maxCol - 1
      elif newPos.col == maxCol: newPos.col = 1
      next.mgetOrPut(newPos, @[]).add dir
  blizzards = next

proc simulate(blizzards: var Blizzards; startPos, endPos: Position): int =
  ## Simulate the blizzards evolution and build the sets of possible
  ## positions of the expedition at each round.
  var positions = @[startPos].toHashSet
  while true:
    inc result
    blizzards.update()
    var next: HashSet[Position]
    for pos in positions:
      if pos notin blizzards:
        next.incl pos   # Waiting is possible.
      for incr in Increments:
        let newPos = pos + incr
        if newPos.row in 1..(maxRow - 1) and newPos.col in 1..(maxCol - 1):
          # Not on the border.
          if newPos notin blizzards:
            next.incl newPos   # Position is free: add it.
        elif newPos == endPos:
          return  # We have reached the exit.
    positions = move(next)

### Part 1 ###

let time = blizzards.simulate(startPos, endPos)
echo "Part 1: ", time


### Part 2 ###

echo "Part 2: ", time + blizzards.simulate(endPos, startPos) + blizzards.simulate(startPos, endPos)
