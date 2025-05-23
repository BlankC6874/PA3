local Drone = require("src.drone")
local Grid = require("src.grid")

function love.load()
    drone = Drone.new()
    grid = Grid.new(10, 8, 64) -- 10x8 tiles, each 64px
end

function love.update(dt)
    drone:update(dt)
end

function love.draw()
    grid:draw()
    drone:draw()
end

function love.keypressed(key)
    drone:keypressed(key)
end