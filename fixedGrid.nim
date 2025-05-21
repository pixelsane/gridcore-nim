const 
  EmptyID* = -1
  GridWidth* = 25
  GridHeight* = 20
  MaxCells* = 500
  MaxEntities* = 50
  MaxPlayers* = 4

type
  ExceedMemory = object of CatchableError
    

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

  GridMap* = array[MaxCells, Cell]
  AllEntities* = array[MaxEntities, Entity]
  PlayersEntities* = array[MaxPlayers, seq[ID]]


var 
  gridMap: GridMap
  allEntities: array[MaxEntities, Entity]
  playersEntities: array[MaxPlayers, seq[ID]]
  entSlot*: int = 0

proc getGridMap*(): var GridMap = gridMap
proc getAllEntities*(): var AllEntities = allEntities
proc getPlayersEntities*(): var PlayersEntities = playersEntities

proc getEntity*(id: int): var Entity =
  assert id >= 0 and id < entSlot, "Entity id out of range"
  allEntities[id]

proc getPlayerEntities*(oid: ID) : seq[ID] =
  assert oid >= 0 and oid < MaxPlayers, "Invalid player ID"
  playersEntities[oid]

proc createEntity*(oid: ID) : ID =
  if entSlot >= MaxEntities:
    raise newException(ExceedMemory, "Exceeded allocated memory slot for entities!")

  var ent = Entity(
    id: entSlot,
    owner_id: oid
  )
  allEntities[entSlot] = ent
  entSlot += 1;
  result = ent.id;

proc prepareGridMap() =
  for i in 0..<MaxCells:
    gridMap[i].occupant = EmptyID

proc prepareEntities() =
  for i in 0..<MaxEntities:
    allEntities[i].id = EmptyID

proc prepareGrid*() = 
  prepareGridMap()
  prepareEntities()

  
func doesEntityExist*(entArr: array[MaxEntities, Entity], id: int) : bool = entArr[id].id == EmptyID

func xOf*(index: ID) : int = index mod GridWidth
func yOf*(index: ID) : int = index div GridHeight
func indexOf*(x: int, y: int) : int = y * GridWidth + x

proc moveEntity*(id: ID, x: int, y: int) =
  var ent = getEntity id
  
  if ent.x >= 0 and ent.y >= 0 and
     ent.x < GridWidth and ent.y < GridHeight:
    let oldIndex = indexOf(ent.x, ent.y)
    if gridMap[oldIndex].occupant == ent.id:
      gridMap[oldIndex].occupant = EmptyID

  ent.x = x
  ent.y = y

  let newIndex = indexOf(x, y)
  gridMap[newIndex].occupant = ent.id
