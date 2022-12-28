import std/[algorithm, sequtils, strutils]

type

  Kind {.pure.} = enum Ore = "ore", Clay = "clay", Obsidian= "obsidian", Geode = "geode"
  Resource = Ore..Obsidian

  Counts = array[Kind, int]         # For robots and products.
  Resources = array[Resource, int]  # For resources used to build robots.

  State = object
    value: int        # Used for states comparisons.
    products: Counts  # Count of products.
    robots: Counts    # Count of robots.

  Blueprint = array[Kind, Resources]

# Build blueprint descriptions.
var blueprints: seq[Blueprint]
for line in lines("p19.data"):
  if line.len == 0: continue
  let parts = line.split(':')
  let segments = parts[1].split('.')   # Ignore first part and split in robot costs segments.
  # Process robot costs segments.
  var blueprint: Blueprint
  for segment in segments:
    var cost = 0
    var robot: Kind
    # Build a robot costs description.
    for field in segment.split(' '):
      if field in ["ore", "clay", "obsidian", "geode"]:
        let kind = parseEnum[Kind](field)
        if cost == 0:
          # This is the robot kind.
          robot = kind
        else:
          # This is a resource kind.
          blueprint[robot][kind] = cost
          cost = 0
      elif field.len > 0 and field[0].isDigit():
        # This is a cost.
        cost = parseInt(field)
  blueprints.add blueprint


proc cmpStates(s1, s2: State): int =
  ## Compare two states.
  cmp(s1.value, s2.value)


proc idNumber(blueprint: Blueprint; roundNum: int): int =
  ## Return the ID number for the given blueprint using "roundNum" rounds.

  type States = seq[State]
  var states: States
  states.add State(products: [0, 0, 0, 0], robots: [1, 0, 0, 0])

  proc initValues(blueprint: Blueprint): Counts =
    ## Return the values used to evaluate the states for comparison.
    ## The values are computed using the resources needed to build a robot.
    result[Ore] = 1
    for kind in Ore..Geode:
      if kind == Ore: result[Ore] = blueprint[Ore][Ore]
      else:
        result[kind] = 0
        for resource in Ore..Obsidian:
          inc result[kind], result[resource] * blueprint[kind][resource]

  let values = blueprint.initValues()

  proc computeValue(state: var State) =
    ## Compute the "value" of a state.
    ## This value is used to compare states when sorting them.
    for kind in Ore..Geode:
      state.value += (state.products[kind] + state.robots[kind]) * values[kind]

  # Run the simulation.
  for _ in 1..roundNum:

    # Create new states.
    var newStates: States
    for state in states:
      # Compute product quantities for next round.
      var nextProducts = state.products
      for kind in Ore..Geode:
        inc nextProducts[kind], state.robots[kind]
      # Add a state without robot creation.
      var newState = State(products: nextProducts, robots: state.robots)
      newState.computeValue()
      newStates.add newState
      # Add states with robot creation.
      for robotKind in countdown(Geode, Ore):  # Create most costly robots first.
        block createRobot:
          for resource in Ore..Obsidian:
            if state.products[resource] < blueprint[robotKind][resource]:
              # Not enough resource. Skip to next one.
              break createRobot
          # Create the robot.
          var newState = State(products: nextProducts, robots: state.robots)
          inc newState.robots[robotKind]
          for resource in Ore..Obsidian:
            dec newstate.products[resource], blueprint[robotKind][resource]
          newState.computeValue()
          newStates.add newState

    # Keep only most relevant states.
    newstates.sort(cmpStates, Descending)     # Faster than using "sortedByIt".
    states = newStates.deduplicate(true)      # Remove duplicates (not necessary by cleaner).
    if states.len > 500: states.setLen(500)   # Keep "best" states.

  # Find the maximum number of geodes produced using this blueprint.
  for state in states:
    let geodes = state.products[Geode]
    if geodes > result:
      result = geodes


### Part 1 ###

var qualityLevel = 0
for i, blueprint in blueprints:
  inc qualityLevel, (i + 1) * blueprint.idNumber(24)

echo "Part 1: ", qualityLevel


### Part 2 ###
var result = 1
for i in 0..2:
  result *= blueprints[i].idNumber(32)

echo "Part 2: ", result
