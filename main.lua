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
local suit = require("libs/suit")
local bitser = require("libs/bitser/bitser")


game = {}
game.manualUpdateSystems = {}
game.state = "menu"
game.ecs = tiny.world()
game.highscore = 0
menu = {}

function game:saveScore()
    local data = {}
    data.highscore = self.highscore
    bitser.dumpLoveFile("highscore.dat", data)
end

function game:loadScore()
    if love.filesystem.getInfo('highscore.dat') then
        local data = bitser.loadLoveFile("highscore.dat")
        game.highscore = data.highscore
    else
        game.highscore = 0
    end
end



function game.load_level()
    tiny.clearEntities(game.ecs)
    tiny.clearSystems(game.ecs)
    game.state = "level"
    local font = love.graphics.newFont(20)
    love.graphics.setFont(font)
    love.graphics.setBackgroundColor(0,0,256)
    game.manualUpdateSystems.camera = system.Camera()
    game.manualUpdateSystems.draw = system.Draw()
    game.manualUpdateSystems.write_score = system.WriteScore()
    game.manualUpdateSystems.overlay = system.Overlay()
    game.manualUpdateSystems.debug_collider = debugsys.Collider()
    game.limits = {
        y = 10000,
        x = 2000
    }
    game.chunk_size_y = 600

    tiny.add(
        game.ecs,
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
        system.ScoreCount(),

        entity.lava(),
        --debugsys.FlyController(),
        --system.OutOfBounds(game.limits.x, game.limits.y),
        game.manualUpdateSystems.camera,
        game.manualUpdateSystems.draw,
        game.manualUpdateSystems.overlay,
        game.manualUpdateSystems.write_score,
        game.manualUpdateSystems.debug_collider
    )

    tiny.addSystem(game.ecs, system.WorldGenerator(game.limits.x, game.chunk_size_y, game.ecs))


end

function love.load()
    print("loaded")
    menu.button_w = 300
    menu.button_x = love.graphics.getWidth()/2 - menu.button_w/2
    menu.button_y = 100
    menu.button_h = 100
    game.state = "menu"
    love.graphics.setBackgroundColor(0,0,0,1)
    game.loadScore()
end


function love.update(dt)
    
    if game.state == "menu" then
        menu.start_button = suit.Button("start",
            menu.button_x,
            menu.button_y,
            menu.button_w,
            menu.button_h
        )

        menu.quit_button = suit.Button("quit",
            menu.button_x,
            menu.button_y + menu.button_h + 20,
            menu.button_w,
            menu.button_h
        )


        if menu.start_button.hit then
            game.load_level()
        end


        if menu.quit_button.hit then
            love.event.quit()
        end

        suit.Label("Highscore: "..game.highscore,
        menu.button_x,
        menu.button_y + menu.button_h*2 + 20,
        menu.button_w,
        menu.button_h )

    elseif game.state == "level" then
        game.ecs:update(dt)
    end

end


function love.draw()
    if game.state == "level" then
        game.manualUpdateSystems.camera:update()
        game.manualUpdateSystems.draw:update()
        game.manualUpdateSystems.overlay:update()
        game.manualUpdateSystems.write_score:update()
        --game.manualUpdateSystems.debug_collider:update()
    elseif game.state == "menu" then
        suit.draw()
    end
end

