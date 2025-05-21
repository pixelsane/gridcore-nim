# Gridcore - Grid System in Nim

A lightweight, modular grid and entity management system written in Nim.  
Designed for 2D grid-based games and simulations, supporting flexible grid sizes, entity tracking, and player ownership.

## Features

- Dynamic or fixed-size grid support  
- Entity creation and management  
- Player-specific entity grouping  
- Coordinate conversions (x/y ↔ index)  
- Easy to extend and embed in your Nim projects  

---

## Installation

Clone the repo or add it as a submodule to your Nim project:

```bash
git clone https://github.com/FunctionallySane4/gridcore-nim
```

---

## Using the Fixed Memory Version

If you want a memory-limited version with fixed-size arrays instead of sequences, check out the `fixedGrid.nim` file. It provides virtually the same API but with compile-time fixed limits on grid size and entity count.

- You will not be passing `grid` to functions anymore, as `fixedGrid` works by mutating globals.

---

## Usage

### Creating a Grid

Create a new grid by specifying the desired width and height:

```nim
let grid = createGrid(25, 20)
```

### Creating Entities

Add entities for players by specifying the owner ID:

```nim
let entityId = createEntity(grid, 0)  # Create an entity owned by player 0
```

### Accessing Entities

Get a mutable reference to an entity by its ID:

```nim
var ent = getEntity(grid, entityId)
ent.x = 5
ent.y = 10
ent.health = 100.0
```

### Working with the Grid

Convert between 2D coordinates and 1D index:

```nim
let index = indexOf(grid, 3, 4)
let x = xOf(grid, index)
let y = yOf(grid, index)
```

In `fixedGrid`, Access to the core grid data is done through getter procs like:
```nim
var grid = getGridMap()
var entities = getAllEntities()
var playerEnts = getPlayersEntities()
```

To create entities and access them safely:

```nim
let id = createEntity(0)
var ent = getEntity(id)
```
Be sure not to exceed `MaxEntities`, `MaxCells`, or `MAX_PLAYERS` as those are compile-time fixed limits.
