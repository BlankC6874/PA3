-- This file is used to configure Enemy class.
-- src/enemy.lua

local Enemy = {}
Enemy.__index = Enemy

function Enemy.new(x, y)
    local self = setmetatable({}, Enemy)
    self.x, self.y = x, y
    self.speed = 1     -- moves every 1 second
    -- self.speed = 0.5
    self.timer = 0
    self.hasDamaged = false -- to prevent multiple damages in one update
    return self
end

function Enemy:update(dt, grid)
    -- stun logic (by suchas EMP)
    if self.stunned and self.stunned > 0 then
        self.stunned = self.stunned - dt
        return
    end

    self.timer = self.timer + dt
    if self.timer < self.speed then return end
    self.timer = 0

    -- Define 4 possible directions
    local directions = {
        {x = 1, y = 0},
        {x = -1, y = 0},
        {x = 0, y = 1},
        {x = 0, y = -1}
    }

    -- Shuffle directions
    for i = #directions, 2, -1 do
        local j = love.math.random(i)
        directions[i], directions[j] = directions[j], directions[i]
    end

    -- Try each direction until one is valid
    for _, dir in ipairs(directions) do
        local nx, ny = self.x + dir.x, self.y + dir.y
        if nx >= 1 and nx <= grid.cols and ny >= 1 and ny <= grid.rows then
            if not grid:isBlocked(nx, ny) then
                self.x = nx
                self.y = ny
            end

            -- destroy powered tiles
            local tile = grid.tiles[ny][nx]
            if tile == grid.TILE.powered then
                grid.tiles[ny][nx] = grid.TILE.broken
                print("Wandering enemy damaged a wire at", nx, ny)
            end

            break
        end
    end
end

function Enemy:draw(tileSize)
    love.graphics.setColor(1, 0, 1)  -- magenta enemy
    love.graphics.rectangle("fill", (self.x - 1) * tileSize, (self.y - 1) * tileSize, tileSize, tileSize)
end

return Enemy