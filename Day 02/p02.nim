import std/[strutils, tables]

type
  Choice {.pure.} = enum Rock = 1, Paper = 2, Scissors = 3
  Outcome {.pure.} = enum Lost = 0, Draw = 3, Won = 6

const
  ABCtoChoice = {"A": Rock, "B": Paper, "C": Scissors}.toTable
  XYZtoChoice = {"X": Rock, "Y": Paper, "Z": Scissors}.toTable
  XYZtoOutcome = {"X": Lost, "Y": Draw, "Z": Won}.toTable


### Part 1 ###

func `<`(c1, c2: Choice): bool =
  ## Return true if "c1" loses against "c2".
  case c1
  of Rock: return c2 == Paper
  of Paper: return c2 == Scissors
  of Scissors: return c2 == Rock

var total = 0
for line in lines("p02.data"):
  if line.len == 0: continue
  let fields = line.split()
  let c1 = ABCtoChoice[fields[0]]
  let c2 = XYZtoChoice[fields[1]]
  if c1 == c2:
    inc total, ord(c2) + ord(Draw)
  elif c1 < c2:
    inc total, ord(c2) + ord(Won)
  else:
    inc total, ord(c2) + ord(Lost)

echo "Part 1: ", total


### Part 2 ###

func choice(c1: Choice; outcome: Outcome): Choice =
  ## Return the choice to play to get the given outcome against choice "c1".
  if outcome == Draw: return c1
  result = case c1
           of Rock: (if outcome == Lost: Scissors else: Paper)
           of Paper: (if outcome == Lost: Rock else: Scissors)
           of Scissors: (if outcome == Lost: Paper else: Rock)

total = 0
for line in lines("p02.data"):
  if line.len == 0: continue
  let fields = line.split()
  let c1 = ABCtoChoice[fields[0]]
  let outcome = XYZtoOutcome[fields[1]]
  let c2 = choice(c1, outcome)
  inc total, ord(c2) + ord(outcome)

echo "Part 2: ", total
