import std/[strscans, strutils]

### Part 1 ###

var cycleNum = 0
var x = 1
var total = 0
for line in lines("p10.data"):
  if line.len == 0: break
  inc cycleNum
  if (cycleNum + 20) mod 40 == 0:
    inc total, x * cycleNum
  var val: int
  if line.scanf("addx $i", val):
    inc cycleNum
    if (cycleNum + 20) mod 40 == 0:
      inc total, x * cycleNum
    inc x, val

echo "Part 1: ", total


### Part 2 ###

type Display = array[6, array[40, char]]
const On = '#'
const Off = ' '   # We use a space instead of a dot to improve legibility.

proc setPixel(display: var Display; cycleNum, x: int) =
  ## On given display, set pixel value according to "cycleNum" and "x" values.
  let xPix = (cycleNum - 1) mod 40
  let yPix = (cycleNum - 1) div 40
  display[yPix][xPix] = if xPix in [x - 1, x, x + 1]: On else: Off

var crt: Display
x = 1
cycleNum = 0
for line in lines("p10.data"):
  if line.len == 0: break
  inc cycleNum
  crt.setPixel(cycleNum, x)
  var val: int
  if line.scanf("addx $i", val):
    inc cycleNum
    crt.setPixel(cycleNum, x)
    inc x, val

echo "Part 2:"
for row in crt:
  echo row.join()
