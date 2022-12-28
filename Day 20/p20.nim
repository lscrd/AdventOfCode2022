# We use a doubly linked ring of nodes containing the values.

import std/[lists, strutils]

type
  Node = DoublyLinkedNode[int]
  Ring = DoublyLinkedRing[int]

const DataFile = "p20.data"

proc buildNodes(): tuple[nodes: seq[Node]; node0: Node] =
  ## Build the ring of nodes.
  var mixed: Ring
  for line in lines(DataFile):
    if line.len == 0: break
    let value = parseInt(line)
    let node = Node(value: value)
    result.nodes.add node
    if value == 0: result.node0 = node
    mixed.append node

proc mix(nodes: seq[Node]) =
  ## Mix the nodes.
  let count = nodes.len
  let m = count - 1
  let lim = nodes.len div 2   # Used to speed up the algorithm.
  for node in nodes:
    # Compute the shift.
    var shift = node.value mod m  # Reduce the shift to a value between 0 and "m".
    # Choose the direction in which to look for the new position.
    if shift > lim: shift = shift - count + 1
    elif shift < -lim: shift = count + shift - 1
    if shift == 0: continue
    # Find the node after which to insert the current node.
    var other = node
    if shift > 0:
      for i in 1..shift:
        other = other.next
    else:
      for i in 1..(-shift + 1):
        other = other.prev
    # Remove the node from current position and move it after node "other.
    node.prev.next = node.next
    node.next.prev = node.prev
    node.prev = other
    node.next = other.next
    other.next.prev = node
    other.next = node

proc coordinatesSum(node0: Node): int =
  var node = node0
  for n in 1..3000:
    node = node.next
    if n in [1000, 2000, 3000]:
      inc result, node.value


### Part 1 ###

var (nodes, node0) = buildNodes()
nodes.mix()

echo "Part 1: ", node0.coordinatesSum()


### Part 2 ###

const DecryptionKey = 811589153
(nodes, node0) = buildNodes()
for node in nodes:
  node.value *= DecryptionKey
for _ in 1..10:
  nodes.mix()

echo "Part 2: ", node0.coordinatesSum()
