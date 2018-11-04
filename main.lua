-- Import the sti tools for working with tiled generated map: 
-- This method most likly demands a .lua version of the map
-- Tutorial link: http://lua.space/gamedev/using-tiled-maps-in-love
-- docs: http://karai17.github.io/Simple-Tiled-Implementation/
-- require "libs.sti"
local tiny = require("libs/tiny")
local system = require "system"
local entity = require "entity"
local component = require "component"
local debugsys = require("debugsys")


game = {}
game.manualUpdateSystems = {}

function love.load()
    game.manualUpdateSystems.camera = system.Camera()
    game.manualUpdateSystems.draw = system.Draw()
    game.manualUpdateSystems.debug_collider = debugsys.Collider()
    game.limits = {
        y = 1000,
        x = 2000
    }
    game.ecs = tiny.world(
        entity.Player(100, 100),
        entity.Platform(100, 300, 300, 100),
        entity.Platform(600, 350, 100, 200),
        
        system.Physics(),
        system.Controller(),
        system.OutOfBounds(game.limits.x, game.limits.y),
        game.manualUpdateSystems.camera,
        game.manualUpdateSystems.draw,
        game.manualUpdateSystems.debug_collider
    )

end


function love.update(dt)
    game.ecs:update(dt)
end


function love.draw()
    game.manualUpdateSystems.camera:update()
    game.manualUpdateSystems.draw:update()
    game.manualUpdateSystems.debug_collider:update()
end
