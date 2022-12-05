# Note: we use hash sets to easily find the common items.

import std/sets

func priority(c: char): int =
  ## Return the priority of an item.
  if c in 'a'..'z':
    ord(c) - ord('a') + 1
  elif c in 'A'..'Z':
    ord(c) - ord('A') + 27
  else:
    raise newException(ValueError, "Not a letter")

### Part 1 ###

var rearrangeList: seq[char]
for line in lines("p03.data"):
  if line.len == 0: continue
  let idx = line.len div 2
  var common = line[0..<idx].toHashSet() * line[idx..^1].toHashSet()
  rearrangeList.add common.pop()

var prioSum = 0
for item in rearrangeList:
  prioSum.inc item.priority
echo "Part 1: ", prioSum


### Part 2 ###

var badges: seq[char]
var idx = 0
var common: HashSet[char]
for line in lines("p03.data"):
  if line.len == 0: continue
  let s = line.toHashSet()
  common = if idx == 0: s else: common * s
  inc idx
  if idx == 3:
    # Terminate group of three.
    idx = 0
    badges.add common.pop()

prioSum = 0
for item in badges:
  prioSum.inc item.priority
echo "Part 2: ", prioSum
