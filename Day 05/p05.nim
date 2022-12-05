import std/[algorithm, strscans, strutils]

type
  Stack = seq[char]
  MoveType {.pure.} = enum SingleCrate, MultipleCrates

proc rearrange(moveType: MoveType): string =
  ## Rearrange the stacks using either multiple moves of single crates
  ## or a single move of multiple crates.
  ## Return the list of crates at top of stacks, as a string.

  let input = open("p05.data")

  # Read stacks contents.
  var line = input.readLine()
  let stackCount = (line.len + 1) div 4
  var stacks = newSeq[Stack](stackCount)
  while true:
    for i in 0..<stackCount:
      let val = line[4*i..(4*i + 2)]
      var crate: char
      if scanf(val, "[$c]", crate):
        stacks[i].add crate
    line = input.readLine()
    if line.startsWith(" 1 "): break

  # Reverse stacks contents.
  for stack in stacks.mitems:
    stack.reverse()

  line = input.readLine() # Skip empty line.
  # Read and execute moves.
  while not input.endOfFile:
    line = input.readLine()
    var count, stStart, stEnd: int
    if scanf(line, "move $i from $i to $i", count, stStart, stEnd):
      if moveType == SingleCrate:
        # Move one crate at a time, reversing their order in stack.
        for i in 1..count:
          stacks[stEnd-1].add stacks[stStart-1].pop()
      else:
        # Move all the crates at once, keeping their order in stack.
        stacks[stEnd-1].add stacks[stStart-1][^count..^1]
        stacks[stStart-1].setLen(stacks[stStart-1].len - count)

  # Find and return the crates at top of stacks.
  for stack in stacks:
    result.add stack[^1]

### Part 1 ###
echo "Part 1: ", rearrange(moveType = SingleCrate)

### Part 2 ###
echo "Part 2: ", rearrange(moveType = MultipleCrates)
