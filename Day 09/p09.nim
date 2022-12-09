import std/[math, sets, strscans]

type Position = tuple[x, y: int]

proc updateTail(tail: var Position; head: Position) =
  ## Update the tail position according head position.
  let dx = tail.x - head.x
  let dy = tail.y - head.y
  # Note that in the second part, both "dx" and "dy" may be equal to 2 or -2
  # which explains why we use the sign of the value instead of the value itself.
  if dx == -2:
    inc tail.x
    dec tail.y, sgn(dy)
  elif dx == 2:
    dec tail.x
    dec tail.y, sgn(dy)
  elif dy == -2:
    dec tail.x, sgn(dx)
    inc tail.y
  elif dy == 2:
    dec tail.x, sgn(dx)
    dec tail.y

# Set of tail positions.
var positions: HashSet[Position]
positions.incl (0, 0)


### Part 1 ###

var head, tail: Position = (0, 0)
for line in lines("p09.data"):
  var dir: char
  var n: int
  if line.scanf("$c $i", dir, n):
    let move = case dir
               of 'L': (-1, 0)
               of 'R': (1, 0)
               of 'U': (0, 1)
               of 'D': (0, -1)
               else: (0, 0)
    for i in 1..n:
      inc head.x, move[0]
      inc head.y, move[1]
      updateTail(tail, head)
      positions.incl tail

echo "Part 1: ", positions.card


### Part 2 ###

var nodes: array[0..9, Position]    # Node 0 is head, node 9 is tail.
positions.clear()
nodes[0] = (0, 0)
positions.incl (0, 0)

for line in lines("p09.data"):
  var dir: char
  var n: int
  if line.scanf("$c $i", dir, n):
    let move = case dir
               of 'L': (-1, 0)
               of 'R': (1, 0)
               of 'U': (0, 1)
               of 'D': (0, -1)
               else: (0, 0)
    for i in 1..n:
      inc nodes[0].x, move[0]
      inc nodes[0].y, move[1]
      # Update each node successively.
      for i in 1..9:
        updateTail(nodes[i], nodes[i-1])
      positions.incl nodes[9]

echo "Part 2: ", positions.card
