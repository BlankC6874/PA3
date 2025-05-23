local Drone = require("src.drone")
local Grid = require("src.grid")
local Parts = require("src.parts")  -- if not already
local Pickup = require("src.pickup")

function love.load()
    drone = Drone.new()
    grid = Grid.new(10, 8, 64) -- 10x8 tiles, each 64px
    pickups = {
    Pickup.new(5, 5, "tool", "solder"),
    Pickup.new(7, 2, "chassis", "heavy")
}
end

function love.update(dt)
    drone:update(dt)
    for _, p in ipairs(pickups) do
        if not p.collected and p.x == drone.x and p.y == drone.y then
            drone:equipPart(p.partType, p.partName)
            p.collected = true
        end
    end
end

function love.draw()
    grid:draw()
    drone:draw()
    for _, p in ipairs(pickups) do
        p:draw(64)
    end
    drone:drawUI()
end

function love.keypressed(key)
    drone:keypressed(key)
end