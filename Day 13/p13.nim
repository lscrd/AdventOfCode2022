import std/[algorithm, parseutils, strutils]

type

  # Packet description.
  PKind = enum pValue, pList  # Kind of packet item.
  PacketItem = ref object     # Item contained in a packet.
    case kind: PKind
    of pValue: value: int
    of pList: list: seq[PacketItem]
  Packet = PacketItem         # A packet is simply a packet item of type list.


proc parsePacket(line: string): Packet =
  ## Parse a line describing a packet.
  var stack: seq[PacketItem]
  var idx = 0
  while idx < line.len:
    case line[idx]
    of '[':
      stack.add PacketItem(kind: pList)
    of ']':
      let pitem = stack.pop()
      if stack.len == 0: return pitem   # Top level packet item.
      stack[^1].list.add pitem
    of '0'..'9':
      var val: int
      idx += line.parseSaturatedNatural(val, idx) - 1
      stack[^1].list.add PacketItem(kind: pValue, value: val)
    of ',':
      discard
    else:
      raise newException(ValueError, "Invalid character")
    inc idx

proc `$`(p: PacketItem): string =
  ## Display a packet item.
  if p.kind == pList:
    result = "["
    for item in p.list:
      result.addSep(",", 1)
      result.add $item
    result.add ']'
  else:
    result = $(p.value)

proc cmp(p1, p2: PacketItem): int =
  ## Compare two packet items.
  ## Return -1 if p1 < p2, 0 if p1 = p2 and 1 is p1 > p2.
  case p1.kind
  of pValue:
    case p2.kind
    of pValue:
      # Compare the values.
      return cmp(p1.value, p2.value)
    of pList:
      # Create a list to contain p1, then compare.
      return cmp(PacketItem(kind: pList, list: @[p1]), p2)
  of pList:
    case p2.kind
    of pValue:
      # Create a list to contain p2, then compare.
      return cmp(p1, PacketItem(kind: pList, list: @[p2]))
    of pList:
      # Compare lists.
      for i in 0..<min(p1.list.len, p2.list.len):
        result = cmp(p1.list[i], p2.list[i])
        if result != 0: return
      return cmp(p1.list.len, p2.list.len)

proc `<`(p1, p2: Packet): bool = cmp(p1, p2) < 0


# Build packet list.
var packets: seq[Packet]
for line in lines("p13.data"):
  if line.len == 0: continue
  packets.add parsePacket(line)


### Part 1 ###
var pairNum = 0
var result = 0
for idx in countup(0, packets.high, 2):
  inc pairNum
  let p1 = packets[idx]
  let p2 = packets[idx + 1]
  if p1 < p2: inc result, pairNum

echo "Part 1: ", result


### Part 2 ###

# Add divider packets.
let p2 = parsePacket("[2]")
let p6 = parsePacket("[6]")
packets.add p2
packets.add p6

# Sort packets and find indexes of divider packets.
packets.sort()
let i1 = packets.find(p2) + 1
let i2 = packets.find(p6) + 1

echo "Part 2: ", i1 * i2
