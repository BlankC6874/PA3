-- This file is used to configure the main loop of game.
-- main.lua

-- Load src files
local Drone = require("src.drone")
local Enemy = require("src.enemy")
local Grid = require("src.grid")
local Parts = require("src.parts")
local Pickup = require("src.pickup")

-- Self-defined constants
local puzzleSolved = false
local droneDead = false
local lastHazardX, lastHazardY = nil, nil

-- game state timers
local waveTimer = 0 -- Timer for enemy waves
local waveInterval = 10 -- seconds between enemy waves

local loopTimer = nil -- Timer for restart game loop after puzzle solved
local loopDelay = 3 -- when loopTimer starts and reaches this value, the game resets

-- love.load is called once at the start of the game
function love.load()
    drone = Drone.new()

    enemies = {
        Enemy.new(10,8),
        -- add more enemies as needed here
    }

    grid = Grid.new(10, 8, 64) -- 10x8 tiles, each 64px
    require("src.grid").instance = grid -- global reference for UI use

    pickups = {
        Pickup.new(5, 5, "tool", "solder"),
        Pickup.new(7, 2, "chassis", "heavy"),
        Pickup.new(3, 6, "tool", "emp"),
        -- add more pickups as needed here
    }
end

-- love.update is called every frame
-- dt is the time since the last frame
function love.update(dt)
    drone:update(dt) -- update drone state

    -- update enemy state
    for _, enemy in ipairs(enemies) do
        enemy:update(dt, grid, loopTimer)  -- targetX, targetY, pass loopTimer to enemy.lua
    end

    -- pickups collectible logic
    for _, p in ipairs(pickups) do
        if not p.collected and p.x == drone.x and p.y == drone.y then
            drone:equipPart(p.partType, p.partName)
            p.collected = true
        end
    end

    -- Damage HERE
    -- hazard tile logic
    if not puzzleSolved and not droneDead then
        local dx, dy = drone.x, drone.y
        if drone:isInHazard(grid) then
            if lastHazardX ~= dx or lastHazardY ~= dy then
                drone.lives = drone.lives - 1
                lastHazardX, lastHazardY = dx, dy
                print("Drone damaged from hazard! Lives left:", drone.lives)

                if drone.lives <= 0 then
                    droneDead = true
                    loopTimer = 0 -- Start the loop countdown
                end
            end
        else
            lastHazardX, lastHazardY = nil, nil  -- Reset when leaving hazard
        end
    end
    -- enemy contact dagame logic
    for _, enemy in ipairs(enemies) do
        if enemy.x == drone.x and enemy.y == drone.y and not enemy.hasDamaged and not droneDead and not puzzleSolved then
            drone.lives = drone.lives - 1
            enemy.hasDamaged = true
            print("Drone collided with enemy! Lives left:", drone.lives)

            if drone.lives <= 0 then
                droneDead = true
                loopTimer = 0 -- Start the loop countdown
            end
        elseif enemy.x ~= drone.x or enemy.y ~= drone.y then
            enemy.hasDamaged = false -- Reset when no longer overlapping
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
                loopTimer = 0 -- Start the loop countdown
                break
            end
        end
    end

    -- Handle enemy waves
    waveTimer = waveTimer + dt
    if waveTimer >= waveInterval then
        waveTimer = 0
        table.insert(enemies, Enemy.new(10, 8))  -- or random spawn
        print("New enemy spawned!")
    end

    -- game loop after puzzle solved
    if puzzleSolved and loopTimer then
        loopTimer = loopTimer + dt
        if loopTimer >= loopDelay then
            loopTimer = nil

            -- Do the same reset as 'R' is pressed
            puzzleSolved = false
            droneDead = false
            lastHazardX, lastHazardY = nil, nil
            love.load()
            print("Game looped automatically after win")
        end
    end

    -- game loop after drone destroyed
    if droneDead and loopTimer then
        loopTimer = loopTimer + dt
        if loopTimer >= loopDelay then
            loopTimer = nil

            -- Do the same reset as 'R' is pressed
            puzzleSolved = false
            droneDead = false
            lastHazardX, lastHazardY = nil, nil
            love.load()
            print("Game looped automatically after drone destroyed")
        end
    end
end

-- love.draw is called every frame to render the game
function love.draw()
    grid:draw() -- Call the function in grid.lua to draw the grid
    drone:draw() -- Call the function in drone.lua to draw the drone at its current position
    
    -- Draw pickups
    for _, p in ipairs(pickups) do
        p:draw(64)
    end
    drone:drawUI()

    -- Draw enemies
    for _, enemy in ipairs(enemies) do
        enemy:draw(64)
    end

    -- Draw UI messages of win/lose conditions
    local screenHeight = love.graphics.getHeight()

    if droneDead then
        love.graphics.setColor(1, 0.3, 0.3)
        love.graphics.print("Drone destroyed!", 10, screenHeight - 50)
    end

    if puzzleSolved then
        love.graphics.setColor(0, 1, 0)
        love.graphics.print("Circuit Repaired!", 10, screenHeight - 30)
    end

    -- Draw message box (automatically disappear) after puzzle solved
    if loopTimer then
        local w, h = love.graphics.getWidth(), love.graphics.getHeight()
        local boxWidth, boxHeight = 300, 80
        local boxX = (w - boxWidth) / 2
        local boxY = (h - boxHeight) / 2

        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", boxX, boxY, boxWidth, boxHeight, 10, 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", boxX, boxY, boxWidth, boxHeight, 10, 10)

        if droneDead then
            love.graphics.printf("Mission Failed. Restarting...", boxX, boxY + 28, boxWidth, "center")
        elseif puzzleSolved then
            love.graphics.printf("Mission Successful. Restarting...", boxX, boxY + 28, boxWidth, "center")
        end
    end
end

-- love.keypressed is called when a key is bound to an action
function love.keypressed(key)
    if loopTimer then return end  -- Disable all key actions during loop countdown
    drone:keypressed(key) -- Call the drone's keypressed function

    -- restart the game if 'r' is pressed
    if key == "r" then
        -- reset the constants
        puzzleSolved = false
        droneDead = false
        lastHazardX, lastHazardY = nil, nil

        -- reload the game state
        love.load()
        print("Game reset!")
    end

    -- EMP action if equipped
    if key == "e" and drone.parts.tool.action == "stun" and not droneDead then
        if drone.empCooldown == 0 then
            for _, enemy in ipairs(enemies) do
                enemy.stunned = 2
            end
            drone.empCooldown = drone.empCooldownMax
            print("EMP triggered: all enemies stunned")
        else
            print("EMP on cooldown:", string.format("%.1f", drone.empCooldown) .. "s remaining")
        end
    end

    -- repair & power action if equipped
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

    -- wall destroy action if equipped
    if key == "c" and drone.parts.tool.action == "cut" then
        local fx, fy = drone.x, drone.y
        if drone.facing == "up" then fy = fy - 1 end
        if drone.facing == "down" then fy = fy + 1 end
        if drone.facing == "left" then fx = fx - 1 end
        if drone.facing == "right" then fx = fx + 1 end

        if fx < 1 or fx > grid.cols or fy < 1 or fy > grid.rows then
            print("Cutter target out of bounds at", fx, fy)
            return
        end

        local target = grid.tiles[fy] and grid.tiles[fy][fx]
        print("Cutter checking tile:", fx, fy, "Type:", target)

        if target == Grid.TILE.wall then
            grid.tiles[fy][fx] = Grid.TILE.empty
            print("Wall destroyed at", fx, fy)
        else
            print("No wall to cut at", fx, fy)
        end
    end

    -- Print current tile information every time you move
    local dx, dy = drone.x, drone.y
    local tile = grid.tiles[dy][dx]
    print("You are on tile:", dx, dy, "Type:", tile)
end