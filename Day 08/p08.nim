type
  Height = 0..9
  Grid = seq[seq[Height]]

var grid: Grid

# Build grid of tree heights.
for line in lines("p08.data"):
  if line.len == 0: continue
  var row: seq[Height]
  for c in line:
    row.add ord(c) - ord('0')
  grid.add row

let maxRowNum = grid.high
let maxColNum = grid[0].high


### Part 1 ###

proc isVisible(grid: Grid; rowNum, colNum: int): bool =
  ## Return true if tree at position (rowNum, ColNum) is visible.
  let height = grid[rowNum][colNum]
  result = true
  for c in countdown(colNum - 1, 0):
    if grid[rowNum][c] >= height:
      result = false
      break
  if result: return
  result = true
  for c in countup(colNum + 1, maxColNum):
    if grid[rowNum][c] >= height:
      result = false
      break
  if result: return
  result = true
  for r in countdown(rowNum - 1, 0):
    if grid[r][colNum] >= height:
      result = false
      break
  if result: return true
  result = true
  for r in countup(rowNum + 1, maxRowNum):
    if grid[r][colNum] >= height:
      result = false
      break

var count = 0
for rowNum in 0..maxRowNum:
  for colNum in 0..maxColNum:
    if grid.isVisible(rowNum, colNum):
      inc count

echo "Part 1: ", count


### Part 2 ###

proc scenicScore(grid: Grid; rowNum, colNum: int): int =
  ## Return the scenic score of tree at position (rowNum, colNum).
  var scoreLeft, scoreRight, scoreTop, scoreBottom = 0
  let startHeight = grid[rowNum][colNum]
  for c in countdown(colNum - 1, 0):
    inc scoreLeft
    if grid[rowNum][c] >= startHeight:
      break
  for c in countup(colNum + 1, maxColNum):
    inc scoreRight
    if grid[rowNum][c] >= startHeight:
      break
  for r in countdown(rowNum - 1, 0):
    inc scoreTop
    if grid[r][colNum] >= startHeight:
      break
  for r in countup(rowNum + 1, maxRowNum):
    inc scoreBottom
    if grid[r][colNum] >= startHeight:
      break
  result = scoreLeft * scoreRight * scoreTop * scoreBottom

var bestScore = 0
for rowNum in 0..maxRowNum:
  for colNum in 0..maxColNum:
    let score = grid.scenicScore(rowNum, colNum)
    if score > bestScore:
      bestScore = score

echo "Part 2: ", bestscore
