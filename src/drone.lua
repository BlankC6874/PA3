local Drone = {}
Drone.__index = Drone

function Drone.new()
    local self = setmetatable({}, Drone)
    self.x, self.y = 2, 2  -- Grid position
    self.speed = 1
    self.color = {0, 1, 0}
    return self
end

function Drone:update(dt)
    -- future: add timed hazards or cooldowns
end

function Drone:keypressed(key)
    if key == "up" then self.y = math.max(1, self.y - 1) end
    if key == "down" then self.y = math.min(8, self.y + 1) end
    if key == "left" then self.x = math.max(1, self.x - 1) end
    if key == "right" then self.x = math.min(10, self.x + 1) end
end

function Drone:draw()
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", (self.x-1)*64, (self.y-1)*64, 64, 64)
    love.graphics.setColor(1, 1, 1)
end

return Drone