import std/[strutils, tables]

type

  EntryType {.pure.} = enum DirEntry, FileEntry

  Entry = ref object
    name: string                      # File or directory name.
    parent: Entry                     # Parent directory.
    size: Natural                     # File size or computed directory total size.
    case entryType: EntryType
    of DirEntry:
      contents: Table[string, Entry]  # Subdirectories.
    of FileEntry:
      discard

var root = Entry(name: "/", entryType: DirEntry)
root.parent = root

# Build the file system hierarchy from the log file.
var curdir = root
for line in lines("p07.data"):
  if line.len == 0: continue
  if line.startsWith("$ cd "):
    # "cd" command: change current directory.
    let dirName = line[5..^1]
    curdir = case dirName
             of "/": root
             of "..": curdir.parent
             else: curdir.contents[dirName]
  elif line.startsWith("$ ls"):
    # "ls" command: do nothing; next lines will provide directory contents.
    discard
  elif line.startsWith("dir "):
    # Add a directory into current directory.
    let dirName = line[4..^1]
    if dirName notin curdir.contents:
      curdir.contents[dirName] = Entry(name: dirName, parent: curdir, entryType: DirEntry)
  else:
    # Add a file into current directory.
    let fields = line.split()
    let size = fields[0].parseInt()
    let name = fields[1]
    if name notin curdir.contents:
      curdir.contents[name] = Entry(name: name, parent: curdir, size: size, entryType: FileEntry)


proc computeSize(dir: Entry) =
  ## Recursively compute the size of "dir".
  assert dir.size == 0
  for entry in dir.contents.values():
    if entry.entryType == DirEntry:
      entry.computeSize()
    inc dir.size, entry.size

root.computeSize()


### Part 1 ###

proc dirs_100000(dir: Entry): seq[Entry] =
  ## Starting from "dir", return the list of directories
  ## whose size is less than or equal to 100_000.
  for entry in dir.contents.values:
    if entry.entryType == DirEntry:
      result.add entry.dirs_100000()
      if entry.size <= 100_000:
        result.add entry

let list = root.dirs_100000()
var totalSize = 0
for dir in list:
  totalSize.inc dir.size

echo "Part 1: ", totalSize


### Part 2 ###

proc dirList(dir: Entry): seq[Entry] =
  ## Starting from "dir", return the list of directories it contains, itself included.
  for entry in dir.contents.values:
    if entry.entryType == DirEntry:
      result.add entry.dirList
  result.add dir

let toFree = 30_000_000 - (70_000_000 - root.size)
var minVal = 70_000_000
var minDir: Entry
for dir in root.dirList:
  if dir.size >= toFree and dir.size < minVal:
    minDir = dir
    minVal = dir.size

echo "Part 2: ", minVal
