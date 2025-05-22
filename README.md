# Gridcore - Grid System in Nim

A lightweight, modular grid system written in Nim.  
Designed for 2D grid-based games and simulations, supporting flexible grid sizes.

## Features

- Dynamic or fixed-size grid support  
- Coordinate conversions (x/y ↔ index)  
- Easy to extend and embed in your Nim projects  

---
*Note: I have trimmed Entity support/system for this library, as it does not make any sense for entity logic merging with grid structures. I have plans on creating a separate entity library however.*

## Installation

Clone the repo or add it as a submodule to your Nim project:

```bash
git clone https://github.com/pixelsane/gridcore-nim/
```

---

## Using the Fixed Memory Version

If you want a memory-limited version with fixed-size arrays instead of sequences, check out the `fixedGrid.nim` file. It provides virtually the same API but with compile-time fixed limits on grid size.

- You will not be passing `grid` to functions anymore, as `fixedGrid` works by mutating globals.

---

## Usage

### Creating a Grid

Create a new grid by specifying the desired width and height:

```nim
let grid = createGrid(25, 20)
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
```
In `fixedGrid`, Be sure not to exceed `MaxCells` as those are compile-time fixed limits. It is therefore highly encouraged to tailor-fit the constants depending on the project's scale.
