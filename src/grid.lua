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
    broken = 5, -- repairable tile
    diodeR = 6, -- right-pointing diode
    hazard = 7, -- hazard tile
    wall = 8, -- wall tile
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

    -- puzzle layout [y][x] -- design the grid map here
    -- HAZARD TILES
    self.tiles[1][4] = TILE.hazard
    self.tiles[1][5] = TILE.hazard
    self.tiles[1][6] = TILE.hazard
    self.tiles[1][7] = TILE.hazard
    self.tiles[6][4] = TILE.hazard
    self.tiles[6][5] = TILE.hazard
    self.tiles[6][6] = TILE.hazard
    self.tiles[6][7] = TILE.hazard
    self.tiles[8][4] = TILE.hazard
    self.tiles[8][5] = TILE.hazard
    self.tiles[8][6] = TILE.hazard
    self.tiles[8][7] = TILE.hazard

    -- WALL TILES
    self.tiles[3][3] = TILE.wall
    self.tiles[3][4] = TILE.wall
    self.tiles[3][5] = TILE.wall
    self.tiles[3][6] = TILE.wall
    self.tiles[3][7] = TILE.wall
    self.tiles[3][8] = TILE.wall
    self.tiles[4][3] = TILE.wall
    self.tiles[4][8] = TILE.wall
    self.tiles[5][3] = TILE.wall
    self.tiles[5][4] = TILE.wall
    self.tiles[5][5] = TILE.wall
    self.tiles[5][6] = TILE.wall
    self.tiles[5][7] = TILE.wall
    self.tiles[5][8] = TILE.wall

    -- PUZZLE TILES
    self.tiles[4][4] = TILE.source
    self.tiles[4][5] = TILE.broken
    self.tiles[4][6] = TILE.diodeR
    self.tiles[4][7] = TILE.target

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
                love.graphics.setColor(1, 1, 0) -- Yellow
                love.graphics.rectangle("fill", tx, ty, self.tileSize, self.tileSize)
            elseif t == TILE.wire then
                love.graphics.setColor(0.6, 0.6, 0.6) -- Grey
                love.graphics.rectangle("fill", tx, ty, self.tileSize, self.tileSize)
            elseif t == TILE.powered then
                love.graphics.setColor(0, 1, 0) -- Green
                love.graphics.rectangle("fill", tx, ty, self.tileSize, self.tileSize)
            elseif t == TILE.target then
                love.graphics.setColor(1, 0, 0) -- Red
                love.graphics.rectangle("fill", tx, ty, self.tileSize, self.tileSize)
            elseif t == TILE.broken then
                love.graphics.setColor(1, 0.5, 0) -- Orange
                love.graphics.rectangle("fill", tx, ty, self.tileSize, self.tileSize)
            elseif t == TILE.diodeR then
                love.graphics.setColor(0.3, 0.3, 1) -- Blue
                love.graphics.polygon("fill",
                    tx + 16, ty + 16,
                    tx + 48, ty + 32,
                    tx + 16, ty + 48
                )
            elseif t == TILE.hazard then
                love.graphics.setColor(0.6, 1, 0) -- Yellow-Green
                love.graphics.rectangle("fill", tx, ty, self.tileSize, self.tileSize)
            elseif t == TILE.wall then
                love.graphics.setColor(0.5, 0.5, 0.5) -- Dark Grey
                love.graphics.rectangle("fill", tx, ty, self.tileSize, self.tileSize)
            end
        end
    end
end

-- Wall Collision Detection
function Grid:isBlocked(x, y)
    if x < 1 or x > self.cols or y < 1 or y > self.rows then
        return true
    end

    local t = self.tiles[y][x]
    return t == Grid.TILE.wall
end

-- When a wire is powered, check whether it's connected to a source,
-- and if so, spread power through adjacent wires, lighting them up automatically.
function Grid:propagatePower()
    local visited = {}
    local queue = {}

    -- Find all source tiles and add to queue
    for y = 1, self.rows do
        for x = 1, self.cols do
            if self.tiles[y][x] == Grid.TILE.source then
                print ("Found source at", x ,y) -- DEBUG OUTPUT
                table.insert(queue, {x = x, y = y})
                visited[y .. "," .. x] = true
            end
        end
    end

    while #queue > 0 do
        local current = table.remove(queue, 1)
        local x, y = current.x, current.y

        -- Check 4 neighbors
        local neighbors = {
            {x = x + 1, y = y},
            {x = x - 1, y = y},
            {x = x, y = y + 1},
            {x = x, y = y - 1},
        }

        for _, n in ipairs(neighbors) do
            if n.x >= 1 and n.x <= self.cols and n.y >= 1 and n.y <= self.rows then
                local tileType = self.tiles[n.y][n.x]
                local key = n.y .. "," .. n.x

                if not visited[key] and (
                    tileType == Grid.TILE.wire or
                    tileType == Grid.TILE.powered or
                    tileType == Grid.TILE.target or
                    tileType == Grid.TILE.diodeR
                ) then
                    -- DIODE FLOW CHECK
                    if tileType == Grid.TILE.diodeR and n.x < x then
                        goto skip  -- skip backward flow through right diode
                    end

                    -- DEBUG OUTPUT
                    print("Propagating to:", n.x, n.y, "type:", tileType)

                    if tileType == Grid.TILE.wire or tileType == Grid.TILE.diodeR then
                        self.tiles[n.y][n.x] = Grid.TILE.powered
                    end

                    visited[key] = true
                    table.insert(queue, n)
                    ::skip::
                end
            end
        end
    end
end

return Grid