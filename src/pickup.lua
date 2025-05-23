local Pickup = {}
Pickup.__index = Pickup

function Pickup.new(x, y, partType, partName)
    local self = setmetatable({}, Pickup)
    self.x = x
    self.y = y
    self.partType = partType
    self.partName = partName
    self.collected = false
    return self
end

function Pickup:draw(tileSize)
    if not self.collected then
        love.graphics.setColor(1, 1, 0)
        love.graphics.circle("fill", (self.x-0.5)*tileSize, (self.y-0.5)*tileSize, tileSize/4)
        love.graphics.setColor(1, 1, 1)
    end
end

return Pickup