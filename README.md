# Nim Grid System

A lightweight, modular grid and entity management system written in Nim.  
Designed for 2D grid-based games and simulations, supporting flexible grid sizes, entity tracking, and player ownership.

## Features

- Dynamic or fixed-size grid support
- Entity creation and management
- Player-specific entity grouping
- Coordinate conversions (x/y ↔ index)
- Easy to extend and embed in your Nim projects

## Installation
```bash
git clone https://github.com/yourusername/nim-grid-system.git```

Clone the repo or add it as a submodule to your Nim project:


## Using the Fixed Memory Version

If you want a memory-limited version with fixed-size arrays instead of sequences, check out the fixedGrid.nim file. It provides virtually the same API but with compile-time fixed limits on grid size and entity count.

* You will not be passing `grid` to functions anymore. As fixedGrid works by mutating globals

---

## Usage

## Creating a Grid

Create a new grid by specifying the desired width and height:
```nim
let grid = createGrid(25, 20)```

## Creating Entities

Add entities for players by specifying the owner ID:
```nim
let entityId = createEntity(grid, 0)  # Create an entity owned by player 0```

## Accessing Entities

Get a mutable reference to an entity by its ID:
```nim
var ent = getEntity(grid, entityId)
ent.x = 5
ent.y = 10
ent.health = 100.0```

## Working with the Grid

Convert between 2D coordinates and 1D index:

```nim
let index = indexOf(grid, 3, 4)
let x = xOf(grid, index)
let y = yOf(grid, index)
```
