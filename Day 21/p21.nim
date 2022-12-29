import std/[math, strutils, tables]

type
  Job = enum jYell, jAdd, jSub, jMul, jDiv
  Monkey = ref object
    name: string
    job: Job
    val: int          # Yelled value or computed value.
    m1, m2: Monkey    # Monkey providers of values for computation.

# Mapping name -> monkey reference.
var monkeys: Table[string, Monkey]

const Jobs = {"+": jAdd, "-": jSub, "*": jMul, "/": jDiv}.toTable
const NoValue = -1000   # Default value for computing monkeys.


proc compute(remaining: seq[Monkey]): int =
  ## Compute the values using the given list of computing monkeys.
  ## Return the value computed by "root" monkey.
  var remaining = remaining
  # Reset "val" attribute.
  for monkey in remaining:
    monkey.val = NoValue

  # Computation loop.
  while true:
    for i in countdown(remaining.high, 0):
      let monkey = remaining[i]
      let val1 = monkey.m1.val
      let val2 = monkey.m2.val
      if val1 != NoValue and val2 != NoValue:
        monkey.val = case monkey.job
                     of jYell: NoValue
                     of jAdd: val1 + val2
                     of jSub: val1 - val2
                     of jMul: val1 * val2
                     of jDiv: val1 div val2
        if monkey.name == "root": return monkey.val
        remaining.delete i


# Build the description of monkeys.
var remaining: seq[Monkey]      # Remaining computing monkeys.
for line in lines("p21.data"):
  if line.len == 0: continue
  let parts = line.split(": ")
  let name = parts[0]
  let fields = parts[1].split()
  if fields.len == 1:
    # Yelling monkey.
    let monkey = monkeys.mgetOrPut(name, Monkey(name: name))
    monkey.job = jYell
    monkey.val = parseInt(fields[0])
  elif fields.len == 3:
    # Computing monkey.
    let name1 = fields[0]
    let m1 = monkeys.mgetOrPut(name1, Monkey(name: name1, val: NoValue))
    let name2 = fields[2]
    let m2 = monkeys.mgetOrPut(name2, Monkey(name: name2, val: NoValue))
    let monkey = monkeys.mgetOrPut(name, Monkey(name: name, val: NoValue))
    monkey.job = Jobs[fields[1]]
    monkey.m1 = m1
    monkey.m2 = m2
    remaining.add monkey
  else:
    raise newException(ValueError, "Unable to parse data file.")

### Part 1 ###

echo "Part 1: ", remaining.compute()


### Part 2 ###

proc setAndCompute(remaining: seq[Monkey]; val: int): int =
  ## Set the value for "humn" and compute.
  monkeys["humn"].val = val
  result = remaining.compute()

# Prepare a binary search.
monkeys["root"].job = jSub    # To compare, we use the subtraction job and check against 0.
var lowVal = 0
let val1 = remaining.setAndCompute(lowVal)
var highVal = 10_000_000_000_000.int  # Choose a bi enough value.
let val2 = remaining.setAndCompute(highVal)
assert sgn(val1) != sgn(val2)         # Computed values must be of different signs.
if val1 > val2: swap lowVal, highVal  # We want first result negative and second result positive.

# Binary search.
var result, val: int
while true:
  result = (lowVal + highVal) div 2
  val = remaining.setAndCompute(result)
  if val == 0: break  # Found a value given a null result.
  if val < 0: lowVal = result
  else: highVal = result

# Try to find a lower value given same result.
while true:
  if remaining.setAndCompute(result - 1) == 0: dec result
  else: break

echo "Part 2: ", result
