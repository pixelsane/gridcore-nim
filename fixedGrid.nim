const 
  EmptyID* = -1
  GridWidth* = 25
  GridHeight* = 20
  MaxCells* = 500

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

proc getGridMap*(): var GridMap = gridMap

proc prepareGridMap(kind: CellKind) =
  for i in 0..<MaxCells:
    gridMap[i].occupant = EmptyID
    gridMap[i].kind = kind

proc prepareGrid*(kind: CellKind) = 
  prepareGridMap(kind)

  
func xOf*(index: ID) : int = index mod GridWidth
func yOf*(index: ID) : int = index div GridHeight
func indexOf*(x: int, y: int) : int = y * GridWidth + x

proc changeKindByIndex*(kind: CellKind, index: int) =
  assert index >= 0 and index < gridMap.len, "Index out of bounds"
  gridMap[index].kind = kind

proc changeKind*(kind: CellKind, x: int, y: int) = changeKindByIndex(kind, indexOf(x, y))

proc changeOccupantByIndex*(occupant: ID, index: int) =
  assert index >= 0 and index < gridMap.len, "Index out of bounds"
  gridMap[index].occupant = occupant
proc changeOccupant*(occupant: ID, x: int, y: int) = changeOccupantByIndex(occupant, indexOf(x, y))

proc cellOfByIndex*(index: int) : var Cell = gridMap[index]
proc cellOf*(x: int, y: int) : var Cell = cellOfByIndex(indexOf(x,y))

proc rightOf*(x: int, y: int, amount: int = 1) : int =
  if x+1 > GridWidth:
    result = -1 # no valid cell
  else:
    result = indexOf(x+amount, y)

proc leftOf*(x: int, y: int, amount: int = 1) : int =
  if x-1 < 0:
    result = -1 # no valid cell
  else:
    result = indexOf(x-amount, y)

proc belowOf*(x: int, y: int, amount: int = 1): int =
  if y + 1 > GridHeight:
    result = -1 # no valid cell
  else:
    result = indexOf(x, y + amount)

proc isOutOfBounds*(x:int, y:int) : bool =
  if x > GridWidth or x < 0 or 
  y > GridHeight or y < 0: 
    result = true
  else:
    result = false

