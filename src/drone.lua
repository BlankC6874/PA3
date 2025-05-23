local Drone = {}
Drone.__index = Drone
local Parts = require("src.parts")

function Drone.new()
    local self = setmetatable({}, Drone)

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

function Drone:update(dt)
    -- Update highlight timers
    for k, t in pairs(self.highlightTimers) do
        if t > 0 then
            self.highlightTimers[k] = math.max(0, t - dt)
        end
    end
    -- future: add timed hazards or cooldowns
end

function Drone:getSpeed()
    return self.parts.chassis.speed
end

function Drone:equipPart(type, name)
    local Parts = require("src.parts")
    if Parts.catalog[type] and Parts.catalog[type][name] then
        self.parts[type] = Parts.catalog[type][name]
        self.highlightTimers[type] = 1  -- 1 second of highlight
        print("Equipped new " .. type .. ": " .. name)
    end
end

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

function Drone:draw()
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", (self.x-1)*64, (self.y-1)*64, 64, 64)
    love.graphics.setColor(1, 1, 1)
end

function Drone:drawUI()
    local screenHeight = love.graphics.getHeight()
    local baseY = screenHeight - 90

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Equipped Parts:", 10, baseY)

    self:printWithFlash("Chassis: " .. self:getPartName("chassis"), 10, baseY + 20, self.highlightTimers.chassis)
    self:printWithFlash("Tool: " .. self:getPartName("tool"), 10, baseY + 40, self.highlightTimers.tool)
    self:printWithFlash("Chip: " .. self:getPartName("chip"), 10, baseY + 60, self.highlightTimers.chip)
end

function Drone:printWithFlash(text, x, y, timer)
    if timer > 0 and math.floor(timer * 4) % 2 == 0 then
        love.graphics.setColor(1, 0, 0)  -- Red
    else
        love.graphics.setColor(1, 1, 1)  -- White
    end
    love.graphics.print(text, x, y)
end

function Drone:getPartName(partType)
    for name, data in pairs(require("src.parts").catalog[partType]) do
        if self.parts[partType] == data then
            return name
        end
    end
    return "unknown"
end

return Drone