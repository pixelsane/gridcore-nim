const 
  EmptyID* = -1

type 
  CellKind* = enum
    Traversable
    Boundary
    Exit

  ID* = int
  Entity* = object
    id, owner_id: ID
    x,y: int
    health: float32

  Cell* = object
    kind: CellKind
    occupant: ID

  Grid* = ref object
    gridMap: seq[Cell]
    gridWidth: int
    gridHeight: int
    allEntities: seq[Entity]
    entSlot: int
    playersEntities: seq[seq[ID]]

proc getEntity*(grid: Grid, id: int): var Entity =
  assert id >= 0 and id < grid.entSlot, "Entity id out of range"
  grid.allEntities[id]

proc getPlayerEntities*(grid: Grid, oid: ID) : seq[ID] =
  grid.playersEntities[oid]

proc createEntity*(grid: Grid, oid: ID): ID =
  let 
    id = grid.allEntities.len

    ent = Entity(
      id: id,
      owner_id: oid,
      x: 0,
      y: 0,
      health: 100.0
    )

  grid.allEntities.add(ent)

  if oid >= grid.playersEntities.len:
    for _ in grid.playersEntities.len..oid:
      grid.playersEntities.add(@[])

  grid.playersEntities[oid].add(id)

  return id

proc createGrid*(width: int, height: int) : Grid =
  var newGrid: Grid
  var gridMap: seq[Cell]
    
  for y in 0..<height:
    for x in 0..<width:
      gridMap.add(Cell(kind: Traversable, occupant: EmptyID))

  newGrid.gridMap = gridMap
  result = newGrid

func xOf*(grid: Grid, index: ID) : int = index mod grid.gridWidth
func yOf*(grid: Grid, index: ID) : int = index div grid.gridHeight
func indexOf*(grid: Grid, x: int, y: int) : int = y * grid.gridWidth + x


proc moveEntity*(grid: Grid, id: ID, x: int, y: int) =
  var ent = getEntity(grid, id)
  
  if ent.x >= 0 and ent.y >= 0 and
     ent.x < grid.gridWidth and ent.y < grid.gridHeight:
    let oldIndex = indexOf(grid, ent.x, ent.y)
    if grid.gridMap[oldIndex].occupant == ent.id:
      grid.gridMap[oldIndex].occupant = EmptyID

  ent.x = x
  ent.y = y

  let newIndex = indexOf(grid, x, y)
  grid.gridMap[newIndex].occupant = ent.id
