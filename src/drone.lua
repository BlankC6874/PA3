-- This file is used to configure drone (player) settings.
-- src/drone.lua

-- Define the Drone class
local Drone = {}
Drone.__index = Drone
local Parts = require("src.parts")

-- Drone class to represent the player's drone
function Drone.new()
    local self = setmetatable({}, Drone)

    -- Initial position and properties
    self.x, self.y = 2, 2
    self.baseSpeed = 1
    self.color = {0, 1, 0}

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
    -- Update highlight timers
    for k, t in pairs(self.highlightTimers) do
        if t > 0 then
            self.highlightTimers[k] = math.max(0, t - dt)
        end
    end
    -- future: add timed hazards or cooldowns
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
    local moveSpeed = self:getSpeed()
    if key == "up" then self.y = math.max(1, self.y - moveSpeed) end
    if key == "down" then self.y = math.min(8, self.y + moveSpeed) end
    if key == "left" then self.x = math.max(1, self.x - moveSpeed) end
    if key == "right" then self.x = math.min(10, self.x + moveSpeed) end
    if key == "space" then
        print("Using tool:", self.parts.tool.action)
    end
end

-- Draw the drone at its current position
function Drone:draw()
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", (self.x-1)*64, (self.y-1)*64, 64, 64)
    love.graphics.setColor(1, 1, 1)
end

-- Draw the UI for equipped parts
function Drone:drawUI()
    local screenWidth = love.graphics.getWidth()
    local baseX = screenWidth - 150  -- adjust if needed

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Equipped Parts:", baseX, 10)

    self:printWithFlash("Chassis: " .. self:getPartName("chassis"), baseX, 30, self.highlightTimers.chassis)
    self:printWithFlash("Tool: " .. self:getPartName("tool"), baseX, 50, self.highlightTimers.tool)
    self:printWithFlash("Chip: " .. self:getPartName("chip"), baseX, 70, self.highlightTimers.chip)
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