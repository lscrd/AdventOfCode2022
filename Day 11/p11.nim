# Note: input parsing is minimalist, limited to what is necessary
# to build the description and, thus, no error detection is done.

import std/strutils

type

  # Operation to compute new worry level.
  OpKind = enum opAdd, opMul, opSquare
  Operation = object
    case kind: OpKind
    of opAdd, opMul: operand: int
    of opSquare: discard

  # Monkey behavior description.
  Monkey = ref object
    items: seq[int]       # List of item worry values.
    operation: Operation  # Operation to compute new worry level.
    testDiv: int          # Value for divisibility test.
    trueTarget: int       # Monkey target if test result is true.
    falseTarget: int      # Monkey target if test result if false.
    inspectCount: int     # Count of item inspections.

  # Operation to use to reduce worry level.
  ReduceKind  = enum redDiv, redMod
  ReduceOperation = tuple[kind: ReduceKind; value: int]

var monkeys: seq[Monkey]

# Build monkey descriptions.
var monkey: Monkey
for line in lines("p11.data"):
  if line.len == 0: continue
  let parts = line.strip().split(':')
  if parts[0].startsWith("Monkey"):
    new(monkey)
    monkeys.add monkey
  else:
    case parts[0]
    of "Starting items":
      var items = parts[1].strip().split(", ")
      for item in items:
        monkey.items.add parseInt(item)
    of "Operation":
      let fields = parts[1].split()
      monkey.operation = if fields[^2] == "+":
                             Operation(kind: opAdd, operand: parseInt(fields[^1]))
                           elif fields[^1] == "old":
                             Operation(kind: opSquare)
                           else:
                             Operation(kind: opMul, operand: parseInt(fields[^1]))
    of "Test":
      monkey.testDiv = parseInt(parts[1].split()[^1])
    of "If true":
      monkey.trueTarget = parseInt(parts[1].split()[^1])
    of "If false":
      monkey.falseTarget = parseInt(parts[1].split()[^1])

# Save monkey descriptions for second part.
let startingState = deepCopy(monkeys)


proc doTurn(monkeys: seq[Monkey]; num: int; redOp: ReduceOperation) =
  ## Execute one turn for a given monkey using given reduce operation.
  let monkey = monkeys[num]
  while monkey.items.len > 0:
    let item = monkey.items.pop()
    inc monkey.inspectCount
    # Compute new worry level.
    var level = case monkey.operation.kind
                of opAdd: item + monkey.operation.operand
                of opMul: item * monkey.operation.operand
                of opSquare: item * item
    level = case redOp.kind
            of redDiv: level div redOp.value
            of redMod: level mod redOp.value
    # Transfer item to another monkey.
    if level mod monkey.testDiv == 0:
      monkeys[monkey.trueTarget].items.add level
    else:
      monkeys[monkey.falseTarget].items.add level


proc doRound(monkeys: seq[Monkey]; redOp: ReduceOperation) =
  ## Execute a round using given reduce operation.
  for i in 0..monkeys.high:
    monkeys.doTurn(i, redOp)


func monkeyBusiness(monkeys: seq[Monkey]): int =
  ## Return the monkey business value.
  var count1, count2 = 0
  for monkey in monkeys:
    let count = monkey.inspectCount
    if count > count1:
      count2 = count1
      count1 = count
    elif count > count2:
      count2 = count
  result = count1 * count2


### Part 1 ###
var redOp: ReduceOperation = (kind: redDiv, value: 3)
for _ in 1..20:
  monkeys.doRound(redOp)

echo "Part 1: ", monkeys.monkeyBusiness()


### Part 2 ###
monkeys = startingState   # Reset to starting state.

# Compute the value for modulo reduction.
# This is the product of the test divisors which are all prime numbers.
redOp = (kind: redMod, value: 1)
for monkey in monkeys:
  redOp.value *= monkey.testDiv

for _ in 1..10_000:
  monkeys.doRound(redOp)

echo "Part 2: ", monkeys.monkeyBusiness()
