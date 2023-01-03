# We could have worked directly with SNAFU numbers as strings, but we
# rather chose to represent SNAFU numbers as sequences of SNAFU digits.

import std/[algorithm, tables]

type
  SnafuDigit {.pure.} = enum MinusTwo = (-2, "=")
                             MinusOne = (-1, "-")
                             Zero = (0, "0")
                             One = (1, "1")
                             Two = (2, "2")
  Snafu = seq[SnafuDigit]

# Mapping from SNAFU digit representations to their values.
const SnafuDigits = {'=': MinusTwo, '-': MinusOne, '0': Zero, '1': One, '2': Two}.toTable

proc toNatural(sVal: Snafu): Natural =
  ## Convert a SNAFU value to a Natural.
  for digit in sVal:
    result = 5 * result + ord(digit)

proc toSnafu(n: Natural): Snafu =
  ## Convert a Natural to a SNAFU value.
  var n = n
  while true:
    let m = n mod 5
    n = n div 5
    case m
    of 3:
      result.add MinusTwo
      inc n
    of 4:
      result.add MinusOne
      inc n
    else:   # 0, 1, 2.
      result.add SnafuDigit(m)
    if n == 0: break
  result.reverse()

proc `$`(sn: Snafu): string =
  ## Return the string representation of a SNAFU number.
  for digit in sn:
    result.add $digit

proc parseSnafu(s: string): Snafu =
  ## Parse a string and return a Snafu number.
  for c in s:
    if c in SnafuDigits:
      result.add SnafuDigits[c]
    else:
      raise newException(ValueError, "invalid SNAFU digit.")


### Part 1 ###

var result = 0
for line in lines("p25.data"):
  if line.len == 0: continue
  inc result, parseSnafu(line).toNatural()

echo "Part 1: ", result.toSnafu()
