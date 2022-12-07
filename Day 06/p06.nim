import std/strutils
var data = readFile("p06.data")
data.stripLineEnd()

func markerPos(data: string; num: int): int =
  ## Return the position in "data" of the first marker of "num" characters.
  var start = 0
  var count = 1
  for idx in 1..data.high:
    let c = data[idx]
    let pos = data.find(c, start, idx - 1)
    if pos >= 0:
      start = pos + 1
      count = idx - pos
    else:
      inc count
      if count == num:
        return idx + 1

### Part 1 ###
echo "Part 1: ", data.markerPos(4)

### Part 2 ###
echo "Part 2: ", data.markerPos(14)
