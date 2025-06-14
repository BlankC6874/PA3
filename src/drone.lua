-- This file is used to configure drone (player) settings.
-- src/drone.lua

-- Define the Drone class
local Drone = {}
Drone.__index = Drone

-- Import the Parts catalog, which contains different parts and their properties
local Parts = require("src.parts")

-- Drone class to represent the player's drone
function Drone.new()
    local self = setmetatable({}, Drone)

    -- Initial position and properties
    self.x, self.y = 2, 2
    self.baseSpeed = 1
    self.color = {0, 1, 0}
    self.lives = 3  -- Number of lives
    self.facing = "down"  -- Initial facing direction

    -- parts cooldown timers
    self.empCooldown = 0   -- current cooldown time
    self.empCooldownMax = 5  -- 5 seconds between uses

    -- Equip default parts
    self.parts = {
        chassis = Parts.catalog.chassis.light,
        tool = Parts.catalog.tool.cutter,
        chip = Parts.catalog.chip.basic
    }

    -- Highlight timers for parts
    self.highlightTimers = {
        chassis = 0,
        tool = 0,
        chip = 0
    }

    return self
end

-- Update the drone's state
function Drone:update(dt)
    -- Update UI highlight timers
    for k, t in pairs(self.highlightTimers) do
        if t > 0 then
            self.highlightTimers[k] = math.max(0, t - dt)
        end
    end

    -- Check for hazards in the grid
    function Drone:isInHazard(grid)
        local x, y = self.x, self.y
        return grid.tiles[y] and grid.tiles[y][x] == require("src.grid").TILE.hazard
    end

    -- Handle EMP cooldown
    if self.empCooldown > 0 then
        self.empCooldown = math.max(0, self.empCooldown - dt)
    end
end

-- Speed is determined by the chassis part
function Drone:getSpeed()
    return self.parts.chassis.speed
end

-- Equip a new part of the specified type
function Drone:equipPart(type, name)
    local Parts = require("src.parts")
    if Parts.catalog[type] and Parts.catalog[type][name] then
        self.parts[type] = Parts.catalog[type][name]
        self.highlightTimers[type] = 1  -- 1 second of highlight
        print("Equipped new " .. type .. ": " .. name)
    end
end

-- Handle key presses for movement and actions
function Drone:keypressed(key)
    if loopTimer then return end
    local moveSpeed = self:getSpeed()

    local dx, dy = 0, 0
    if key == "up" then
        self.facing = "up"
        dy = -1
    elseif key == "down" then
        self.facing = "down"
        dy = 1
    elseif key == "left" then
        self.facing = "left"
        dx = -1
    elseif key == "right" then
        self.facing = "right"
        dx = 1
    end

    for step = 1, moveSpeed do
        local nextX = self.x + dx
        local nextY = self.y + dy

        if nextX < 1 or nextX > grid.cols or nextY < 1 or nextY > grid.rows then
            break -- hit edge of grid
        end

        if grid:isBlocked(nextX, nextY) then
            break -- hit wall
        end

        self.x = nextX
        self.y = nextY
    end
end

-- Draw the drone at its current position, with a flashing grey edge
function Drone:draw()
    local px = (self.x - 1) * 64
    local py = (self.y - 1) * 64

    -- Flashing grey edge (alternates every 0.25s)
    if math.floor(love.timer.getTime() * 4) % 2 == 0 then
        love.graphics.setColor(0.6, 0.6, 0.6)  -- Grey
        love.graphics.setLineWidth(4)
        love.graphics.rectangle("line", px, py, 64, 64)
    end

    -- Drone body
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", px + 8, py + 8, 48, 48)

    love.graphics.setColor(1, 1, 1)  -- Reset color
end

-- Draw the UI for equipped parts & anything drone-related
function Drone:drawUI()
    local screenWidth = love.graphics.getWidth()
    local baseX = screenWidth - 150  -- adjust if needed

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Equipped Parts:", baseX, 10)
    self:printWithFlash("Chassis: " .. self:getPartName("chassis"), baseX, 30, self.highlightTimers.chassis)
    self:printWithFlash("Tool: " .. self:getPartName("tool"), baseX, 50, self.highlightTimers.tool)
    self:printWithFlash("Chip: " .. self:getPartName("chip"), baseX, 70, self.highlightTimers.chip)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Lives: " .. self.lives, baseX, 90)

    -- Hazard warning
    if self:isInHazard(require("src.grid").instance) then
        love.graphics.setColor(1, 0.3, 0.3)  -- Red for hazard
        love.graphics.print("IN HAZARD ZONE!", baseX, 110)
    end

    -- EMP cooldown display
    if self.parts.tool.action == "stun" then
        local cd = self.empCooldown
        local msg = cd > 0 and ("EMP Cooldown: " .. string.format("%.1f", cd) .. "s") or "EMP Ready"
        love.graphics.print(msg, baseX, 120)

        -- Check if any enemy is stunned
        local stunned = false
        for _, enemy in ipairs(enemies) do
            if enemy.stunned and enemy.stunned > 0 then
                stunned = true
                break
            end
        end
        -- Display enemy stun status
        if stunned then
            love.graphics.print("Enemy stunned", baseX, 140)
        end
    end
end

-- Print text with a flashing effect based on the timer
function Drone:printWithFlash(text, x, y, timer)
    if timer > 0 and math.floor(timer * 4) % 2 == 0 then
        love.graphics.setColor(1, 0, 0)  -- Red
    else
        love.graphics.setColor(1, 1, 1)  -- White
    end
    love.graphics.print(text, x, y)
end

-- Get the name of equipped parts
function Drone:getPartName(partType)
    for name, data in pairs(require("src.parts").catalog[partType]) do
        if self.parts[partType] == data then
            return name
        end
    end
    return "unknown"
end

return Drone