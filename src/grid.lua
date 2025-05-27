-- This file is used to configure grid settings.

-- Define the Grid class
local Grid = {}
Grid.__index = Grid

-- Define the tile types
local TILE = {
    empty = 0,
    source = 1,
    wire = 2,
    target = 3,
    powered = 4,
}

-- Make it accessible outside this file
Grid.TILE = TILE

-- Grid class to represent the game grid
function Grid.new(cols, rows, tileSize)
    local self = setmetatable({}, Grid)

    self.cols = cols
    self.rows = rows
    self.tileSize = tileSize

    self.tiles = {}
    for y = 1, self.rows do
        self.tiles[y] = {}
        for x = 1, self.cols do
            self.tiles[y][x] = TILE.empty
        end
    end

    -- puzzle layout [y][x]
    self.tiles[4][4] = TILE.source
    self.tiles[4][5] = TILE.wire
    self.tiles[4][6] = TILE.target

    return self
end

-- Function to set new tiles at (x, y) to a specific type
function Grid:draw()
    love.graphics.setColor(0.2, 0.2, 0.2)
    for i = 0, self.cols - 1 do
        for j = 0, self.rows - 1 do
            love.graphics.rectangle("line", i * self.tileSize, j * self.tileSize, self.tileSize, self.tileSize)
        end
    end
    love.graphics.setColor(1, 1, 1)

    for y = 1, self.rows do
        for x = 1, self.cols do
            local tx, ty = (x - 1) * self.tileSize, (y - 1) * self.tileSize
            local t = self.tiles[y][x]
            if t == TILE.source then
                love.graphics.setColor(1, 1, 0)
                love.graphics.rectangle("fill", tx, ty, self.tileSize, self.tileSize)
            elseif t == TILE.wire then
                love.graphics.setColor(0.6, 0.6, 0.6)
                love.graphics.rectangle("fill", tx, ty, self.tileSize, self.tileSize)
            elseif t == TILE.powered then
                love.graphics.setColor(0, 1, 0)
                love.graphics.rectangle("fill", tx, ty, self.tileSize, self.tileSize)
            elseif t == TILE.target then
                love.graphics.setColor(1, 0, 0)
                love.graphics.rectangle("fill", tx, ty, self.tileSize, self.tileSize)
            end
        end
    end
end

return Grid