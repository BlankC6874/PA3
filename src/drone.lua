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

    return self
end

function Drone:update(dt)
    -- future: add timed hazards or cooldowns
end

function Drone:getSpeed()
    return self.parts.chassis.speed
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

return Drone