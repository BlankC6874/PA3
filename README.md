# Circuit Breaker

**Circuit Breaker** is a top-down grid-based puzzle game built with [LÖVE (Love2D)](https://love2d.org/).  
You control a modular repair drone that must restore power to damaged circuits while avoiding hazards and managing limited lives.

![Screenshot](screenshot.png)

---

## 🕹 Gameplay Overview

- Power up grid tiles by repairing and activating wires.
- Equip and swap modular parts to change abilities.
- Avoid environmental hazards — you only have 3 lives!
- Reach the terminal by completing the circuit to win.

---

## 🔧 Controls & Parts

- Arrow keys: Move the drone
- `Space`: Use equipped (by pick-up) SOLDER tool
- `C`: Use equipped (by default) CUTTER tool
- `E`: Use equipped (by pick-up) EMP Tool
- `R`: Restart the current level

- **Chasis:**
	- light **(DEFAULT)**: Fast movement speed (2), low armor (1)
	- heavy (pick-up): Slower movement (1), but higher durability (3)
- **Tools**
	- cutter **(DEFAULT)**: Destroys wall tiles when used while facing them (C key)
	- solder (pick-up): Repairs broken wires and powers up circuits (Space key)
	- emp (pick-up): Temporarily stuns all enemies with an area-wide shock (E key), includes cooldown of 5s
- **Chips**
	- basic **(DEFAULT)**: Default chip with 3 HP/Lives
	- navChip (planned): FUTURE

---

## 📁 Folder Structure
/circuit-breaker/
- main.lua – Game entry point
- conf.lua – LÖVE configuration
- src/
    - drone.lua – Player drone logic and UI
	- enemy.lua - Enemy movement logic
	- grid.lua – Tile grid system and power propagation
	- parts.lua – Drone part definitions (chassis, tools, chips)
	- pickup.lua – Part pickup system

---

## 🚀 Requirements

- [LÖVE 11.4+](https://love2d.org/) must be installed on your system

---

## 📦 Running the Game

 - See [this documentation](https://love2d.org/wiki/Getting_Started) titled Getting Started from [LÖVE wiki](https://love2d.org/wiki/Main_Page)