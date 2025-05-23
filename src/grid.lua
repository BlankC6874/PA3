local Grid = {}
Grid.__index = Grid

function Grid.new(cols, rows, tileSize)
    local self = setmetatable({}, Grid)
    self.cols, self.rows = cols, rows
    self.tileSize = tileSize
    return self
end

function Grid:draw()
    love.graphics.setColor(0.2, 0.2, 0.2)
    for i = 0, self.cols - 1 do
        for j = 0, self.rows - 1 do
            love.graphics.rectangle("line", i * self.tileSize, j * self.tileSize, self.tileSize, self.tileSize)
        end
    end
    love.graphics.setColor(1, 1, 1)
end

return Grid