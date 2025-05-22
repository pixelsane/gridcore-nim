import nico
import ../../../grid.nim

const orgName = "fsane"
const appName = "nicostacker"

const 
  tileHeight = 5
  tileWidth = 5
  rows = 15
  columns = 15
  playfield_x = 0
  playfield_y = 0
  LEFT = 0x00
  RIGHT = 0x01

var 
  buttonPressed = false
  playfield = createGrid(columns,rows, Unfilled)

proc gameInit() =
  loadFont(0, "font.png")

var
  cursorX = 0
  cursorY = rows - 1
  cursorSize = 4
  cursorSpeed = 0.3
  cursorSpeedDec = 0.032
  cursorTimer = 0.0
  cursorDirection = RIGHT

proc clearCursor() =
  if cursorDirection == RIGHT:
    for i in 0..<cursorSize:
      let x = if cursorDirection == RIGHT: cursorX + i else: cursorX - i
      if x >= 0 and x < columns:
        changeKind(playfield, Unfilled, x, cursorY)
  else:
    for i in 0..<cursorSize - 1:
      if not((cursorX - i) <= -1):
        changeKind(playfield, Unfilled, cursorX - i, cursorY)

proc moveCursorRight() =
    cursorX += 1

proc moveCursorLeft() =
    cursorX -= 1

proc cursorUpdate() =
  clearCursor()
  if cursorX >= columns:
    cursorDirection = LEFT
  elif cursorX <= 0:
    cursorDirection = RIGHT

  if cursorTimer > cursorSpeed:
    if cursorDirection == RIGHT:
      moveCursorRight()
    else:
      moveCursorLeft()
    cursorTimer = 0

  for i in 0..<cursorSize:
    let x = if cursorDirection == RIGHT: cursorX + i else: cursorX - i
    if x >= 0 and x < columns:
      changeKind(playfield, Filled, x, cursorY)

proc removeNotStacked() =
  discard
  

proc placeStack() =
  if(buttonPressed):
    removeNotStacked()
    cursorSpeed -= cursorSpeedDec
    cursorY -= 1
    cursorX = -1
  
proc gameUpdate(dt: float32) =
  buttonPressed = btnup(pcA)
  cursorTimer += dt
  cursorUpdate()
  placeStack()

proc renderPlayfield() =
  for y in 0..<playfield.gridHeight:
    for x in 0..<playfield.gridWidth:
      let
        index = indexOf(playfield, x, y)
        cell = playfield.gridMap[index]

      let
        x0 = (x * tileWidth) + playfield_x
        y0 = (y * tileHeight) + playfield_y
        x1 = (x0 + tileWidth)
        y1 = (y0 + tileHeight)

      if(cell.kind == Unfilled):
        setColor(2)
        rect(x0, y0, x1, y1)
      else:
        setColor(6)
        rectfill(x0, y0, x1, y1)

proc gameDraw() =
  setColor(0)
  cls()
  renderPlayfield()


nico.init(orgName, appName)
nico.createWindow(appName, 110, 76, 4, false)
nico.run(gameInit, gameUpdate, gameDraw)
