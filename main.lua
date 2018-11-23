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
    love.graphics.setBackgroundColor(0,0,256)
    game.manualUpdateSystems.camera = system.Camera()
    game.manualUpdateSystems.draw = system.Draw()
    game.manualUpdateSystems.overlay = system.Overlay()
    game.manualUpdateSystems.debug_collider = debugsys.Collider()
    game.limits = {
        y = 10000,
        x = 2000
    }
    game.chunk_size_y = 600

    game.ecs = tiny.world(
        --entity.Platform(100, 300, 300, 100),
        --entity.Platform(600, 350, 100, 200),
        entity.Platform(love.graphics.getWidth()/2 -200,200, 400, 100),
        --entity.Platform(0, -game.chunk_size_y/2, love.graphics.getWidth()/2, game.chunk_size_y),
        --entity.Platform(0,game.chunk_size_y + love.graphics.getHeight(), love.graphics.getWidth()/2, game.chunk_size_y),
        entity.Player(love.graphics.getWidth()/2,0),
        --entity.DebugFlyPlayer(love.graphics.getWidth()/2, 0),
        
        --system.MoveNoCollision(),
        system.Input(),
        system.Controller(),
        system.Gravity(),
        system.MoveWithCollision(),
        system.Gripping(),

        --entity.lava(),
        --debugsys.FlyController(),
        --system.OutOfBounds(game.limits.x, game.limits.y),
        game.manualUpdateSystems.camera,
        game.manualUpdateSystems.draw,
        game.manualUpdateSystems.overlay,
        game.manualUpdateSystems.debug_collider
    )

    tiny.addSystem(game.ecs, system.WorldGenerator(game.limits.x, game.chunk_size_y, game.ecs))

end


function love.update(dt)
    game.ecs:update(dt)
end


function love.draw()
    game.manualUpdateSystems.camera:update()
    game.manualUpdateSystems.draw:update()
    game.manualUpdateSystems.overlay:update()
    --game.manualUpdateSystems.debug_collider:update()
end
