-- This file is used to configure the main loop of game.
-- main.lua

-- Load src files
local Drone = require("src.drone")
local Grid = require("src.grid")
local Parts = require("src.parts")  -- if not already
local Pickup = require("src.pickup")

-- Self-defined constants
local puzzleSolved = false
local droneDead = false
local lastHazardX, lastHazardY = nil, nil

-- love.load is called once at the start of the game
function love.load()
    drone = Drone.new()
    grid = Grid.new(10, 8, 64) -- 10x8 tiles, each 64px
    require("src.grid").instance = grid -- global reference for UI use

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

    -- WIN CONDITION
    local tx, ty = 7, 4 -- assuming target tile is at (7, 4)

    if not puzzleSolved and grid.tiles[ty] and grid.tiles[ty][tx] == Grid.TILE.target then
        -- check if neighbor is powered
        local neighbors = {
            {x = tx - 1, y = ty}, -- <- (6,4)
            {x = tx + 1, y = ty},
            {x = tx, y = ty - 1},
            {x = tx, y = ty + 1},
        }

        for _, n in ipairs(neighbors) do
            if grid.tiles[n.y] and grid.tiles[n.y][n.x] == Grid.TILE.powered then
                print("Puzzle Solved!")
                puzzleSolved = true
                break
            end
        end
    end

    -- HAZARD CHECK: Lose 1 life per enter hazard tile
    if not puzzleSolved and not droneDead then
        local dx, dy = drone.x, drone.y
        if drone:isInHazard(grid) then
            if lastHazardX ~= dx or lastHazardY ~= dy then
                drone.lives = drone.lives - 1
                lastHazardX, lastHazardY = dx, dy
                print("⚠️ Drone took damage! Lives left:", drone.lives)

                if drone.lives <= 0 then
                    droneDead = true
                end
            end
        else
            lastHazardX, lastHazardY = nil, nil  -- Reset when leaving hazard
        end
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

    local screenHeight = love.graphics.getHeight()

    if droneDead then
        love.graphics.setColor(1, 0.3, 0.3)
        love.graphics.print("Drone destroyed!", 10, screenHeight - 50)
    end

    if puzzleSolved then
        love.graphics.setColor(0, 1, 0)
        love.graphics.print("Circuit Repaired!", 10, screenHeight - 30)
    end
end

-- love.keypressed is called when a key is bound to an action
function love.keypressed(key)
    drone:keypressed(key)

    if key == "r" then
        -- reset the constants
        puzzleSolved = false
        droneDead = false
        lastHazardX, lastHazardY = nil, nil

        -- reload the game state
        love.load()
        print("Game reset!")
    end

    if key == "space" and drone.parts.tool.action == "repair" then
        print("Pressed space with tool:", drone.parts.tool.action)

        local dx, dy = drone.x, drone.y
        if grid.tiles[dy] then
            local tile = grid.tiles[dy][dx]

            if tile == Grid.TILE.broken then
                grid.tiles[dy][dx] = Grid.TILE.wire
                print("Repaired broken wire at", dx, dy)
            elseif tile == Grid.TILE.wire then
                grid.tiles[dy][dx] = Grid.TILE.powered
                print("Activated wire at", dx, dy)
                grid:propagatePower()  -- ← THIS MUST BE HERE
            end
        end
    end

    -- Print current tile information every time you move
    local dx, dy = drone.x, drone.y
    local tile = grid.tiles[dy][dx]
    print("You are on tile:", dx, dy, "Type:", tile)
end