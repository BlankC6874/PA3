-- This file is used to configure the main loop of game.
-- main.lua

-- Load src files
local Drone = require("src.drone")
local Grid = require("src.grid")
local Parts = require("src.parts")  -- if not already
local Pickup = require("src.pickup")

-- Self-defined constants
local gameWon = false

-- love.load is called once at the start of the game
function love.load()
    drone = Drone.new()
    grid = Grid.new(10, 8, 64) -- 10x8 tiles, each 64px
    pickups = {
    Pickup.new(5, 5, "tool", "solder"),
    Pickup.new(7, 2, "chassis", "heavy")
}
end

-- love.update is called every frame
-- dt is the time since the last frame
function love.update(dt)
    drone:update(dt)
    for _, p in ipairs(pickups) do
        if not p.collected and p.x == drone.x and p.y == drone.y then
            drone:equipPart(p.partType, p.partName)
            p.collected = true
        end
    end

    -- WIN = if the wire just before the target is powered
    local tx, ty = 6, 4
    local prevX = tx - 1  -- = 5
    if not gameWon and grid.tiles[ty] and grid.tiles[ty][prevX] == Grid.TILE.powered then
        print("Puzzle Solved!")
        gameWon = true
    end
end

-- love.draw is called every frame to render the game
function love.draw()
    grid:draw()
    drone:draw()
    for _, p in ipairs(pickups) do
        p:draw(64)
    end
    drone:drawUI()

    if gameWon then
        love.graphics.setColor(0, 1, 0)
        local screenHeight = love.graphics.getHeight()
        love.graphics.print("✅ Circuit Repaired!", 10, screenHeight - 30)
    end
end

-- love.keypressed is called when a key is bound to an action
function love.keypressed(key)
    drone:keypressed(key)

    if key == "space" and drone.parts.tool.action == "repair" then
        local dx, dy = drone.x, drone.y
        if grid.tiles[dy] and grid.tiles[dy][dx] == Grid.TILE.wire then
            grid.tiles[dy][dx] = Grid.TILE.powered
            print("Activated wire at", dx, dy)
        end
    end
end