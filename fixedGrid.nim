const 
  EmptyID* = -1
  GridWidth* = 8
  GridHeight* = 8
  MaxCells* = GridWidth * GridHeight

# Add or remove types according to need
type 
  CellKind* = enum
    Default
    Filled
    Unfilled
    A
    B
    C
    D
    Empty
    Terrain
    Traversable
    Boundary
    Exit

  ID* = int

  Cell* = object
    kind: CellKind
    occupant: ID

  GridMap* = array[MaxCells, Cell]

var 
  gridMap: GridMap

func xOf*(index: ID) : int = index mod GridWidth
func yOf*(index: ID) : int = index div GridHeight
func indexOf*(x: int, y: int) : int = y * GridWidth + x

proc assertIndex(index: int) = 
  assert index >= 0 and index < gridMap.len, "Index out of bounds"

proc kind*(index: int) : CellKind =
  assertIndex index
  return gridMap[index].kind

proc kindOf*(x: int, y: int) : CellKind =
  return kind(indexOf(x,y))

proc occupant*(index: int) : ID =
  assertIndex index
  return gridMap[index].occupant

proc occupantOf*(x: int, y: int) : ID =
  return occupant(indexOf(x,y))
proc getGridMap*(): var GridMap = gridMap

proc prepareGridMap(kind: CellKind) =
  for i in 0..<MaxCells:
    gridMap[i].kind = kind

proc prepareGrid*(kind: CellKind) = 
  prepareGridMap(kind)
  
proc changeKindByIndex*(kind: CellKind, index: int) =
  assertIndex index
  gridMap[index].kind = kind

proc changeKind*(kind: CellKind, x: int, y: int) = changeKindByIndex(kind, indexOf(x, y))

proc changeOccupantByIndex*(occupant: ID, index: int) =
  assertIndex index
  gridMap[index].occupant = occupant
proc changeOccupant*(occupant: ID, x: int, y: int) = changeOccupantByIndex(occupant, indexOf(x, y))

proc cellOfByIndex*(index: int) : var Cell = gridMap[index]
proc cellOf*(x: int, y: int) : var Cell = cellOfByIndex(indexOf(x,y))

proc indexRightOf*(x: int, y: int, amount: int = 1) : int =
  if x+1 > GridWidth:
    result = -1 # no valid cell
  else:
    result = indexOf(x+amount, y)

proc indexLeftOf*(x: int, y: int, amount: int = 1) : int =
  if x-1 < 0:
    result = -1 # no valid cell
  else:
    result = indexOf(x-amount, y)

proc indexBelowOf*(x: int, y: int, amount: int = 1): int =
  if y + 1 > GridHeight:
    result = -1 # no valid cell
  else:
    result = indexOf(x, y + amount)

proc belowOf*(x: int, y: int, amount: int = 1): Cell =
  cellOf x, y + amount

proc isOutOfBounds*(x:int, y:int) : bool =
  if x > GridWidth or x < 0 or 
  y > GridHeight or y < 0: 
    result = true
  else:
    result = false

proc clearColumn*(row: int, clearKind: CellKind = Empty) =
  let
    startingColumn = row * GridWidth
    endingColumn = (row * GridWidth) + GridWidth

  for i in startingColumn ..< endingColumn:
    changeKindByIndex clearKind, i
    changeOccupantByIndex EmptyID, i
