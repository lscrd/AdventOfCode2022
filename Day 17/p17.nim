import std/sequtils

const
  # Rocks described starting from last row.
  Rocks = [@["####"],
           @[".#.", "###", ".#."],
           @["###", "..#", "..#"],
           @["#", "#", "#", "#"],
           @["##", "##"]]
  EmptyRow = "......."        # Used to fill the new rows.
  MaxCol = EmptyRow.high      # Last column number.

type
  Tower = seq[string]         # Bottom is at index 0.
  Position = tuple[r, c: int]
  Positions = seq[Position]


# Read the jet pattern.
let jetPattern = readLines("p17.data", 1)[0]


proc applyJet(rockPos: var Positions; tower: Tower; jet: char) =
  ## Apply current jet to rock, modifying its positions.
  var newPos: Positions
  for pos in rockPos:
    if jet == '<':
      # Move left.
      if pos.c == 0 or tower[pos.r][pos.c - 1] == '#':
        # Unable to move.
        return
      newPos.add (pos.r, pos.c - 1)
    else:
      # Move right.
      if pos.c == MaxCol or tower[pos.r][pos.c + 1] == '#':
        # Unable to move.
        return
      newPos.add (pos.r, pos.c + 1)
  rockPos = move(newPos)


proc moveDown(rockPos: var Positions; tower: Tower): bool =
  # Try to move the rock down.
  # If successful, the rock positions are updated.
  var newPos: Positions
  for pos in rockPos:
    if pos.r == 0 or tower[pos.r - 1][pos.c] == '#':
      # Unable to move.
      return false
    newPos.add (pos.r - 1, pos.c)
  rockPos = move(newPos)
  result = true


proc towerHeight(roundCount: Natural): int =
  ## Compute the height of the tower after "rouncCount" rounds.
  const Lim = 100   # Maximal height before reduction of the tower.
  type
    Heights = array[7, int]   # Reduced heights of each column.
    State = object
      rockIndex: int          # Index of current rock.
      jetIndex: int           # Index of current jet.
      heights: Heights        # Column reduced heights.

  var tower: Tower
  var state = State(rockIndex: -1, jetIndex: -1)
  var states: seq[tuple[round: int; height: int; state: State]]
  var currHeight = 0    # Height of current (maybe reduced) tower.
  var round = 0
  while round < roundCount:
    inc round
    state.rockIndex = (state.rockIndex + 1) mod Rocks.len

    # Make room for a new rock.
    tower.setLen(currHeight + 3)
    for i in currHeight..tower.high:
      tower[i] = EmptyRow

    # Set rock at the top.
    var rockPos: seq[Position]
    for rockRow in Rocks[state.rockIndex]:
      tower.add EmptyRow
      for i, rockElem in rockRow:
        if rockElem == '#':
          rockPos.add (tower.high, i + 2)

    # Move rock.
    while true:
      state.jetIndex = (state.jetIndex + 1) mod jetPattern.len
      rockPos.applyJet(tower, jetPattern[state.jetIndex])
      if not rockPos.moveDown(tower): break

    # Set rock in position.
    for pos in rockPos:
      tower[pos.r][pos.c] = '#'
      if pos.r >= state.heights[pos.c]:
        state.heights[pos.c] = pos.r + 1
      if pos.r >= currHeight:
        currHeight = pos.r + 1

    # Remove bottom if tower is too large.
    let minHeight = min(state.heights)
    if minHeight > Lim:
      # Remove bottom of tower.
      let count = minHeight - Lim
      tower.delete(0..<count)
      for h in state.heights.mitems:
        dec h, count
      inc result, count
      dec currHeight, count

      # Check for a cycle.
      var idx = states.high
      while idx >= 0 and state != states[idx].state:
        dec idx
      if idx < 0:
        # Not found in existing states. Add a new state.
        states.add (round, result, state)
      else:
        # Found a cycle. Use it to speed up the computation.
        let heightDiff = result - states[idx].height
        let cycleRounds = round - states[idx].round
        let cycleCount = (roundCount - round) div cycleRounds
        inc result, cycleCount * heightDiff
        inc round, cycleCount * cycleRounds
        states.setLen(0)  # Just to minimize memory usage for next rounds.

  # Add the remaining height (the height of the last reduced tower).
  inc result, currHeight


### Part 1 ###
echo "Part 1: ", towerHeight(2022)

### Part 2 ###
echo "Part 2: ", towerHeight(1_000_000_000_000)
