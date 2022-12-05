import std/[algorithm, math, strutils]

type Food = seq[int]
var inventory: seq[Food]

var food: Food
for line in lines("p01.data"):
  if line.len != 0:
    food.add parseInt(line)
  else:
    inventory.add food
    food = @[]

# Add last sequence if not already done.
if food.len != 0:
  inventory.add food

# Compute the sum of calories carried by each elf.
var calories: seq[int]
for food in inventory:
  calories.add sum(food)

### Part 1 ###
# We don't need to keep track of elf number, only the total calories.
calories.sort(Descending)
echo "Part 1: ", calories[0]

### Part 2 ###
echo "Part 2: ", calories[0] + calories[1] + calories[2]
