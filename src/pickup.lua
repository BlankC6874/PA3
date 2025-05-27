-- This file is used to configure the pickup capability.

-- Define the Pickup class
local Pickup = {}
Pickup.__index = Pickup

-- Pickup class to represent collectible parts in the game
function Pickup.new(x, y, partType, partName)
    local self = setmetatable({}, Pickup)
    self.x = x
    self.y = y
    self.partType = partType
    self.partName = partName
    self.collected = false
    return self
end

-- Function to update the pickup state
function Pickup:draw(tileSize)
    if not self.collected then
        love.graphics.setColor(1, 1, 0)
        love.graphics.circle("fill", (self.x-0.5)*tileSize, (self.y-0.5)*tileSize, tileSize/4)
        love.graphics.setColor(1, 1, 1)
    end
end

return Pickup