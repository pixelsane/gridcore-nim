const 
  EmptyID* = -1

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
    kind*: CellKind
    occupant*: ID

  Grid* = ref object
    gridMap*: seq[Cell]
    gridWidth*: int
    gridHeight*: int

func xOf*(grid: Grid, index: ID) : int = index mod grid.gridWidth
func yOf*(grid: Grid, index: ID) : int = index div grid.gridHeight
func indexOf*(grid: Grid, x: int, y: int) : int = y * grid.gridWidth + x

proc kind*(grid: Grid, index: int) : CellKind =
  assertIndex index
  return grid.gridMap[index].kind

proc kindOf*(grid: Grid, x: int, y: int) : CellKind =
  return kind(grid, indexOf(x,y))

proc occupant*(grid: Grid, index: int) : ID =
  assertIndex index
  return grid.gridMap[index].occupant

proc occupantOf*(grid:Grid, x: int, y: int) : ID =
  return occupant(grid, indexOf(x,y))

proc createGrid*(width: int, height: int, kind: CellKind = Unfilled) : Grid =
  var newGrid: Grid = new Grid
  var gridMap: seq[Cell]
  newGrid.gridWidth = width
  newGrid.gridHeight = height
    
  for y in 0..<height:
    for x in 0..<width:
      gridMap.add(Cell(kind: kind, occupant: EmptyID))

  newGrid.gridMap = gridMap
  result = newGrid

proc changeKindByIndex*(grid: Grid, kind: CellKind, index: int) =
  assert index >= 0 and index < grid.gridMap.len, "Index out of bounds"
  grid.gridMap[index].kind = kind
proc changeKind*(grid: Grid, kind: CellKind, x: int, y: int) = changeKindByIndex(grid, kind, indexOf(grid, x, y))

proc changeOccupantByIndex*(grid: Grid, occupant: ID, index: int) =
  assert index >= 0 and index < grid.gridMap.len, "Index out of bounds"
  grid.gridMap[index].occupant = occupant
proc changeOccupant*(grid: Grid, occupant: ID, x: int, y: int) = changeOccupantByIndex(grid, occupant, indexOf(grid, x, y))

proc cellOfByIndex*(grid: Grid, index: int) : var Cell = grid.gridMap[index]
proc cellOf*(grid: Grid, x: int, y: int) : var Cell = cellOfByIndex(grid, indexOf(grid,x,y))

proc indexRightOf*(grid: Grid, x: int, y: int, amount: int = 1) : int =
  if x+1 > grid.gridWidth:
    result = -1 # no valid cell
  else:
    result = indexOf(grid, x+amount, y)
proc indexLeftOf*(grid: Grid, x: int, y: int, amount: int = 1) : int =
  if x-1 < 0:
    result = -1 # no valid cell
  else:
    result = indexOf(grid, x-amount, y)
proc indexBelowOf*(grid: Grid, x: int, y: int, amount: int = 1): int =
  if y + 1 > grid.gridHeight:
    result = -1 # no valid cell
  else:
    result = indexOf(grid, x, y + amount)

proc isOutOfBounds*(grid: Grid, x:int, y:int) : bool =
  if x > grid.gridWidth or x < 0 or 
  y > grid.gridHeight or y < 0: 
    result = true
  else:
    result = false

proc clearColumn*(grid: grid, row: int, clearKind = Empty) =
  let
    startingColumn = row * grid.gridWidth
    endingColumn = (row * grid.gridWidth) + grid.gridWidth

  for i in startingColumn ..< endingColumn:
    changeKindByIndex grid, clearKind, i
    changeOccupantByIndex grid, EmptyID, i
