import nico
import ../../../grid.nim

const orgName = "fsane"
const appName = "nicostacker"

const 
  screenW = 110
  screenH = 76
  tileHeight = 5
  tileWidth = 5
  rows = 15
  columns = 15
  playfield_x = 0
  playfield_y = 0
  LEFT = 0x00
  RIGHT = 0x01

type Screen = enum
  Gameplay
  Win
  Lose

var 
  buttonPressed = false
  playfield: Grid
  screen: Screen
  best: int
  current: int

var
  cursorX: int
  cursorY: int
  cursorColor: int
  cursorSize: int
  cursorSpeed: float32
  cursorSpeedDec: float32
  cursorTimer: float32
  cursorDirection: int

proc startGame() =
  current = 0
  screen = Gameplay
  playfield = createGrid(columns,rows, Unfilled)
  cursorX = 0
  cursorY = rows - 1
  cursorColor = 6
  cursorSize = 4
  cursorSpeed = 0.3
  cursorSpeedDec = 0.030
  cursorTimer = 0.0
  cursorDirection = RIGHT

proc gameInit() =
  loadFont(0, "font.png")
  startGame()


proc cursorBounds(): tuple[start, stop: int] =
  if cursorDirection == RIGHT:
    (cursorX, cursorX + cursorSize - 1)
  else:
    (cursorX - (cursorSize - 1), cursorX)

proc clearCursor() =
  let
    startX = if cursorDirection == RIGHT: cursorX else: cursorX - (cursorSize - 1)
  for i in 0..<cursorSize:
    let x = startX + i
    if x >= 0 and x < columns:
      changeKind(playfield, Unfilled, x, cursorY)

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

  let (start, stop) = cursorBounds()
  for x in start..stop:
    if x >= 0 and x < columns:
      changeKind(playfield, Filled, x, cursorY)

proc removeNotStacked() =
  var newSize = cursorSize
  let startX = if cursorDirection == RIGHT: cursorX else: cursorX - (cursorSize - 1)

  for i in 0..<cursorSize:
    let x = startX + i
    let belowIndex = belowOf(playfield, x, cursorY)
    if belowIndex in 0..<playfield.gridMap.len:
      let belowKind = playfield.gridMap[belowIndex].kind
      if belowKind == Unfilled:
        newSize -= 1

  cursorSize = max(0, newSize)

proc removeOvertacked() =
  for i in 0..<cursorSize:
    let 
      x = if cursorDirection == RIGHT: cursorX + i else: cursorX - i
      belowOfIndex = belowOf(playfield, x, cursorY)
      belowKind = playfield.gridMap[belowOfIndex].kind
    if x >= 0 and x < columns:
      if belowKind == Unfilled:
        changeKind(playfield, Unfilled, x, cursorY)
      else:
        changeKind(playfield, Filled, x, cursorY)
  

proc placeStack() =
  if(buttonPressed):
    removeOvertacked()
    removeNotStacked()
    cursorSpeed -= cursorSpeedDec
    current += 1
    cursorY -= 1
    cursorX = -1

proc loseDraw() =
  setColor 2
  print("Game Over!", (screenW / 3) - 8, screenH / 2, 1)
  if buttonPressed:
    startGame()

proc winDraw() =
  setColor 2
  print("You Won!", (screenW / 3) - 8, screenH / 2, 1)
  if buttonPressed:
    startGame()
  
proc winCondition() =
  if cursorY <= -1 and cursorSize > 0:
    screen = Win

  
proc gameUpdate(dt: float32) =
  buttonPressed = btnup(pcA)
  if (screen == Lose or screen == Win) and current > best:
    best = current

  if cursorSize <= 0:
    current -= 1
    screen = Lose

  if(cursorY <= int(rows / 6)):
    cursorColor = 8
  elif(cursorY <= int(rows / 4)):
    cursorColor = 3
  elif(cursorY <= int(rows / 2)):
    cursorColor = 7

  winCondition()
  if screen == Gameplay:
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
        setColor cursorColor
        rectfill(x0, y0, x1, y1)

proc displayScore() =
  setColor(6)
  printr($current & "m", screenW - 2, 8, 1)
  setColor(2)
  printr($best & "m", screenW - 2, 1, 1)

proc gameDraw() =
  setColor(0)
  cls()
  case screen 
  of Gameplay:
    displayScore()
    renderPlayfield()
  of Lose:
    loseDraw()
  of Win:
    winDraw()

nico.init(orgName, appName)
nico.createWindow(appName, screenW, screenH, 4, false)
nico.run(gameInit, gameUpdate, gameDraw)
