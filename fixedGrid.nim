const 
  EmptyID = -1
  GridWidth = 25
  GridHeight = 20
  MaxCells = 500
  MaxEntities = 50
  MaxPlayers = 4

type
  ExceedMemory = object of CatchableError
    

type 
  CellKind = enum
    Traversable
    Boundary
    Exit

  ID = int
  Entity = object
    id, owner_id: ID
    x,y: int
    health: float32

  Cell = object
    kind: CellKind
    occupant: ID


var 
  gridMap: array[MaxCells, Cell]
  allEntities: array[MaxEntities, Entity]
  entSlot: int = 0
  playersEntities: array[MAX_PLAYERS, seq[ID]]


proc getEntity*(id: int): var Entity =
  assert id >= 0 and id < entSlot, "Entity id out of range"
  allEntities[id]

proc getPlayerEntities*(oid: ID) : seq[ID] =
  assert oid >= 0 and oid < MaxPlayers, "Invalid player ID"
  playersEntities[oid]

proc createEntity(oid: ID) : ID =
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

proc prepareScene() = 
  prepareGridMap()
  prepareEntities()

func doesEntityExist*(entArr: array[MaxEntities, Entity], id: int) : bool = entArr[id].id == EmptyID

func xOf*(index: ID) : int = index mod GridWidth
func yOf*(index: ID) : int = index div GridHeight
func indexOf*(x: int, y: int) : int = y * GridWidth + x

proc init() =
  prepareScene()

  discard createEntity(0);
  discard createEntity(1);
  discard createEntity(2);

  echo doesEntityExist(allEntities, 0)
  echo doesEntityExist(allEntities, 5)

init()
