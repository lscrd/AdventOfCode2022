import std/[algorithm, sets, tables]

type
  Position = (int, int)
  Area = HashSet[Position]
  Direction {.pure.} = enum North, South, West, East

const Increments = [North: [(-1, -1), (-1,  0), (-1,  1)],
                    South: [( 1, -1), ( 1,  0), ( 1,  1)],
                    West:  [(-1, -1), ( 0, -1), ( 1, -1)],
                    East:  [(-1,  1), ( 0,  1), ( 1,  1)]]

proc `+`(pos, incr: Position): Position =
  ## Add an increment to a position.
  (pos[0] + incr[0], pos[1] + incr[1])

proc freeNeighbors(area: Area; pos: Position): int =
  ## Return the number of free tiles around a position.
  ## The current position is included which means that
  ## the lowest value is 1 and the highest is 8.
  for rowIncr in [-1, 0, 1]:
    for colIncr in [-1, 0, 1]:
      if (pos[0] + rowIncr, pos[1] + colIncr) notin area:
        inc result

proc okToMove(area: Area; pos: Position; dir: Direction): bool =
  # Check if it is possible to move from given position in given direction.
  for incr in Increments[dir]:
    if pos + incr in area:
      return false
  return true

proc simulate(area: var Area; roundCount = -1): int =
  ## Simulate the movements of elves for the given number of rounds.
  ## If the number of rounds is not specified (or negative), stop
  ## when no move is possible and return the number of rounds executed.

  # Prioritized list of directions (will be rotated at each round).
  var directions = [North, South, West, East]

  while result != roundCount:

    # First half of round: check neighbor positions and propose a move.
    inc result
    var proposals: Table[Position, Position]
    for pos in area:
      if area.freeNeighbors(pos) != 8:
        for dir in directions:
          if area.okToMove(pos, dir):
            proposals[pos] = pos + Increments[dir][1]
            break
    directions.rotateLeft(1)
    if proposals.len == 0: break  # No possible move.

    # Second half of the round: find actual moves and apply.
    var newPos: Table[Position, Position]     # Map new to previous positions of elves.
    var moves: Table[Position, Position]      # Map old to new positions of elves.
    for startPos, endPos in proposals.pairs:
      if endPos in newPos:
        # Position already chosen. Remove the possible move.
        let pos = newPos[endPos]
        if pos in moves: moves.del(pos)
      else:
        # New possible position. Add the possible move.
        newPos[endPos] = startPos
        moves[startPos] = endPos
    # Execute the remaining moves.
    for startPos, endpos in moves.pairs:
      area.excl startPos
      area.incl endPos

# Build the description of the area.
var area1: Area
var row = -1
for line in lines("p23.data"):
  inc row
  if line.len == 0: break
  for col, ch in line:
    if ch == '#':
      area1.incl (row, col)

var area2 = area1   # Copy for part 2.


### Part 1 ###
discard area1.simulate(10)

# Compute the number of empty tiles.
var minRow, minCol = 1_000_000
var maxRow, maxCol = -1_000_000
for pos in area1:
  if pos[0] < minRow: minRow = pos[0]
  elif pos[0] > maxRow: maxRow = pos[0]
  if pos[1] < minCol: minCol = pos[1]
  elif pos[1] > maxCol: maxCol= pos[1]

echo "Part 1: ", (maxRow - minRow + 1) * (maxCol - minCol + 1) - card(area1)


### Part 2 ###

echo "Part 2: ", area2.simulate()
