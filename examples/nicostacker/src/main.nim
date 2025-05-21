import nico
import ../../../grid.nim

const orgName = "fsane"
const appName = "nicostacker"

const 
  tileWidth = 5
  tileHeight = 5
  playfield_x = 20
  playfield_y = 20

var 
  buttonPressed = false
  playfield = createGrid(10,10, Unfilled)

proc gameInit() =
  loadFont(0, "font.png")

proc gameUpdate(dt: float32) =
  buttonPressed = btnup(pcA)

proc renderPlayfield() =
  setColor(1)
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
        rect(x0, y0, x1, y1)
      else:
        rectfill(x0, y0, x1, y1)



proc gameDraw() =
  setColor(0)
  cls()
  renderPlayfield()
  changeKind(playfield, Filled, 0, 1)


nico.init(orgName, appName)
nico.createWindow(appName, 128, 128, 4, false)
nico.run(gameInit, gameUpdate, gameDraw)
