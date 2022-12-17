#[ Implementation note.

This is an improved version of our first solution.
First, to store the valves to open, we replaced the hash set we used by a simple sequence.
As the size of this sequence is small, the performance is improved significantly.
Second, we replaced the names of the valves by pointers which avoids the indirection through
a hash table and thus improves significantly the performance. The hash table is only used when
building the description of valves.

On our computer, in release mode with default memory manager, the program runs in about 450 ms.
But, if we switch to “arc” memory manager, it runs in about 60 ms, which is an impressive
improvement.

]#

import std/[algorithm, strutils,sugar, tables]

type Valve = ref object
  name: string
  rate: int
  neighbors: seq[Valve]

var valves: Table[string, Valve]    # Mapping name -> valve description.
var toOpen: seq[Valve]              # Valves to open.

for line in lines("p16.data"):
  if line.len == 0: continue
  # Extract data from line.
  let fields = line.split()
  let name = fields[1]
  let rate = parseInt(fields[4][5..^2])
  let names = collect:
                for i in 9..fields.high:
                  fields[i].strip(leading = false, trailing = true, {','})
  # Build valve description.
  if name notin valves:
    valves[name] = Valve(name: name)
  let valve = valves[name]
  valve.rate = rate
  if rate != 0 and valve notin toOpen:
    toOpen.add valve
  for n in names:
    if n notin valves:
      valves[n] = Valve(name: n)
    valve.neighbors.add valves[n]

let start = valves["AA"]


### Part 1 ###

proc pressure1(start: Valve; toOpen: seq[Valve]): int =
  ## Compute the pressure released with one actor working during 30 minutes.

  # Description of a possible state.
  type State = object
    current: Valve      # Current position.
    previous: Valve     # Previous position.
    toOpen: seq[Valve]  # Remaining valves to open.
    totalRate: int      # Current total rate.
    pressure: int       # Current pressure released.

  let initialState = State(current: start, previous: start,
                           toOpen: toOpen, totalRate: 0, pressure: 0)
  var states = @[initialState]  # List of possible states for each minute.
  for time in 1..30:
    var nextStates: seq[State]  # List of possible states for next minute.
    for state in states:
      let pressure = state.pressure + state.totalRate

      # If no more valves to open, only update the pressure.
      if state.toOpen.len == 0:
        var newState = state
        newState.pressure = pressure
        nextStates.add newState
        continue

      # Open the valve if useful.
      if state.current in state.toOpen:
        var newState = state
        newState.toOpen.del newState.toOpen.find(state.current)
        inc newState.totalRate, state.current.rate
        newState.pressure = pressure
        nextStates.add newState

      # Move to another valve.
      for next in state.current.neighbors:
        if next != state.previous or state.current.rate != 0:
          var newState = State(current: next, previous: state.current,
                               toOpen: state.toOpen, totalRate: state.totalRate,
                               pressure: pressure)
          nextStates.add newState

    # Sort the new states by decreasing value of pressure
    # and keep only the first thousand ones.
    states = sortedByIt(nextStates, -it.pressure)
    if states.len > 1000: states.setLen(1000)

  result = states[0].pressure


echo "Part 1: ", pressure1(start, toOpen)


### Part 2 ###

proc pressure2(start: Valve; toOpen: seq[Valve]): int =
  ## Compute the pressure released with two actors working during 26 minutes.

  type State = object
    current1, current2: Valve     # Current positions.
    previous1, previous2: Valve   # Previous positions.
    toOpen: seq[Valve]            # Remaining valves to open.
    totalRate: int                # Current total rate.
    pressure: int                 # Current pressure released.

  let initialState = State(current1: start, current2: start,
                           previous1: start, previous2: start,
                           toOpen: toOpen, totalRate: 0, pressure: 0)
  var states = @[initialState]    # List of possible states for each minute.
  for t in 1..26:
    var nextStates: seq[State]    # List of possible states for next minute.
    for state in states:
      let pressure = state.pressure + state.totalRate

      # If no more valves to open, only update the pressure.
      if state.toOpen.len == 0:
        var newState = state
        newState.pressure = pressure
        nextStates.add newState
        continue

      # Move both actors to another valve.
      for next1 in state.current1.neighbors:
        if next1 != state.previous1 or state.current1.rate != 0:
          for next2 in state.current2.neighbors:
            if next2 != state.previous2 or state.current2.rate != 0:
              let newState = State(current1: next1, current2: next2,
                                   previous1: state.current1, previous2: state.current2,
                                   toOpen: state.toOpen, totalRate: state.totalRate,
                                   pressure: pressure)
              nextStates.add newState

      # Open valve of first actor if useful.
      if state.current1 in state.toOpen:
        var baseState = state
        baseState.toOpen.del baseState.toOpen.find(state.current1)
        inc baseState.totalRate, state.current1.rate
        baseState.pressure = pressure
        # Move second actor to another valve.
        for next2 in state.current2.neighbors:
          if next2 != state.previous2 or state.current2.rate != 0:
            var newState = baseState
            newState.current2 = next2
            newState.previous2 = state.current2
            nextStates.add newState
        # Open valve of second actor if useful.
        if state.current2 != state.current1 and state.current2 in state.toOpen:
          var newState = baseState
          newState.toOpen.del newState.toOpen.find(state.current2)
          inc newState.totalRate, state.current2.rate
          newState.pressure = pressure
          nextStates.add newState

      # Open valve of second actor if useful and move first actor.
      if state.current2 in state.toOpen:
        var baseState = state
        baseState.toOpen.del baseState.toOpen.find(state.current2)
        inc baseState.totalRate, state.current2.rate
        baseState.pressure = pressure
        # Move first actor to another valve.
        for next1 in state.current1.neighbors:
          if next1 != state.previous1 or state.current1.rate != 0:
            var newState = baseState
            newState.current1 = next1
            newState.previous1 = state.current1
            nextStates.add newState

    # Sort the new states by decreasing value of pressure
    # and keep only the first thousand ones.
    states = sortedByIt(nextStates, -it.pressure)
    if states.len > 1000: states.setLen(1000)

  result = states[0].pressure


echo "Part 2: ", pressure2(start, toOpen)
