import nico
import std/tables, std/sets, std/sequtils
import fixedGrid
import random

type TransitionState = enum
  In
  Out
  None

const 
  authName = "pixelsane"
  appName = "Braindead Gem Collector"

const
  gridSizePx = 16
  gems = [Opal, Topaz, Diamond, Peridot]
  gemsFrames = {Opal: 0, Topaz: 1, Diamond: 2, Peridot: 3, Empty: -1}.toTable
  minX = 1
  minY = 1
  maxX = 6
  maxY = 6 

var 
  score: int = 0
  selector: array[3, CellKind]
  selectorX = 2
  selectorY = 0
  transitionState = None
  transitionY = 0.0

proc drawScore =
  print $score, 4, 120

proc transitionIn =
  if transitionState == In: return
  if transitionState == None:
    transitionY = 0.0
  transitionState = In

proc transitionOut =
  if transitionState == Out: return
  if transitionState == None:
    transitionY = 128.0
  transitionState = Out

proc isTransitionInOver : bool =
  if transitionState == In and transitionY >= 127.0:
    transitionState = None
    return true
  else:
    return false

proc transition =
  let x = 128
  setColor 2
  if transitionState == In:
    transitionY = lerp(transitionY, 128.0, 0.05)
  elif transitionState == Out:
    transitionY = lerp(transitionY, 0.0, 0.05)

  rectFill 0, 0, x, transitionY


proc randomGem : CellKind =
  gems[rand(3)]

proc findMatchesAround*(x, y: int): seq[(int, int)] =
  let targetKind = kindOf(x, y)
  var visited = initHashSet[(int, int)]()
  var toVisit = @[(x, y)]

  while toVisit.len > 0:
    let (cx, cy) = toVisit.pop()
    if (cx, cy) in visited or isOutOfBounds(cx, cy):
      continue

    if kindOf(cx, cy) == targetKind:
      visited.incl((cx, cy))
      for (nx, ny) in [
        (cx+1, cy), (cx-1, cy), (cx, cy+1), (cx, cy-1),   # orthogonal
        (cx+1, cy+1), (cx-1, cy+1), (cx+1, cy-1), (cx-1, cy-1)  # diagonal
      ]:
        if not ((nx, ny) in visited) and not isOutOfBounds(nx, ny):
          toVisit.add((nx, ny))

  return toSeq(visited)

proc findAllMatches(minMatchLen: int = 3): seq[(int, int)] =
  var visited = initHashSet[(int, int)]()
  var resultSeq: seq[(int, int)] = @[]

  for y in 0..<GridHeight:
    for x in 0..<GridWidth:
      if (x, y) in visited or kindOf(x, y) == Empty:
        continue

      let group = findMatchesAround(x, y)
      if group.len >= minMatchLen:
        for cell in group:
          visited.incl(cell)
          resultSeq.add(cell)

  return resultSeq

proc clearMatches() =
  let matches = findAllMatches()
  for (x, y) in matches:
    score += 1
    changeKind(Empty, x, y)

proc placeLowest(x,y : int, k: CellKind) =
  if kindOf(x, y + 1) == Empty and y < maxY:
    placeLowest(x, y + 1, k)
    return

  changeKind k, x, y

proc placeGems =
  placeLowest selectorX, selectorY, selector[0]
  placeLowest selectorX + 1, selectorY, selector[1]
  placeLowest selectorX + 2, selectorY, selector[2]

proc applyGravity() =
  for x in minX .. maxX:
    for y in countdown(maxY , minY):
      let k = kindOf(x, y)
      if k != Empty:
        changeKind(Empty, x, y)
        placeLowest(x, y, k)

proc drawBG(enableGrid: bool = false) =
  setSpritesheet 0
  spr 0, 0, 0
  if enableGrid:
    setSpritesheet 1
    spr 0, 0, 0

proc drawGrid(grid: GridMap) =
  let matches = findAllMatches()
  for i in 0..grid.len - 1:
    let 
      kind = kind(i)
      gemFrame = gemsFrames[kind]
      x = xOf(i)
      y = yOf(i)
      shouldGlow = (x, y) in matches and y >= minY
    
    if shouldGlow:
      setSpritesheet 4
    else:
      setSpritesheet 3

    spr gemFrame, x * gridSizePx, y * gridSizePx

proc drawSelector =
  clearColumn 0
  changeKind selector[0], selectorX, selectorY
  changeKind selector[1], selectorX + 1, selectorY
  changeKind selector[2], selectorX + 2, selectorY

proc resetSelector =
  selector[0] = Empty
  selector[1] = Empty
  selector[2] = Empty

proc populateSelector = 
  selector[0] = randomGem()
  selector[1] = randomGem()
  selector[2] = randomGem()

proc isAllFilled(grid: GridMap): bool =
  for i in 0 ..< grid.len:
    if kind(i) == Empty and
       yOf(i) >= minY and yOf(i) <= maxY and
       xOf(i) >= minX and xOf(i) <= maxX:
      return false
  return true

proc nextChest(grid: GridMap) =
  if not(isAllFilled(grid)): return
  clearMatches()
  selectorX = 2

proc gameInit =
  randomize()
  setPalette (loadPaletteFromGPL "ayy4.gpl")
  loadSfx 0, "green_sound.ogg"
  loadSfx 1, "red_sound.ogg"
  loadSpriteSheet 0, "bg.png", 128, 128
  loadSpriteSheet 1, "grid.png", 128, 128
  loadSpriteSheet 2, "selector.png", 16, 16
  loadSpriteSheet 3, "gems.png", 16, 16
  loadSpriteSheet 4, "gemsGlow.png", 16, 16

  prepareGrid Empty
  populateSelector()
  transitionOut()

proc gameUpdate(dt: float32) =
  let
    canLeft = selectorX > minX 
    canRight = selectorX + 2 < maxX
    grid = getGridMap()

  if btnpr(pcLeft) and canLeft: selectorX -= 1
  if btnpr(pcRight) and canRight: selectorX += 1
  if btnpr(pcA): 
    placeGems()
    resetSelector()
    populateSelector()
    sfx 0,0
    if isAllFilled(grid): sfx(0,1)

  nextChest grid
  applyGravity()


proc gameDraw() =
  cls()
  drawBG true
  drawGrid getGridMap()
  drawSelector()
  drawScore()
  transition()

nico.init(authName, appName)
nico.createWindow(appName, 128, 128, 4, false)
nico.run(gameInit, gameUpdate, gameDraw)
