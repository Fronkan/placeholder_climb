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
local hump_camera = require("libs/hump/camera")

local OPTIONS = "options"
local MENU = "menu"
local LEVEL = "level"

game = {}
game.manualUpdateSystems = {}
game.state = MENU
game.ecs = tiny.world()
game.highscore = 0
game.scale = 0.5
game.camera = hump_camera(love.graphics.getWidth()/2,0, game.scale, 0)
menu = {}
menu.options = {}

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

function game:removeScore()
    local wasRemoved = false
    if love.filesystem.getInfo('highscore.dat') then
        wasRemoved = love.filesystem.remove('highscore.dat')
        game.highscore = 0
    end
    return wasRemoved
end

function game:load_options()
    self.state = OPTIONS
end

function game:load_mainmenu()
    self.state = MENU
end


function game.load_level()
    tiny.clearEntities(game.ecs)
    tiny.clearSystems(game.ecs)
    game.state = LEVEL
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
    game.chunk_size_y = 600 * 1/game.scale

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
        system.Accelerator(),
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

    tiny.addSystem(game.ecs, system.WorldGenerator(love.graphics.getWidth()/game.scale, game.chunk_size_y, game.ecs))


end

function love.load()
    -- Create menu
    menu.controlls = love.graphics.newImage("assets/controlls.png")
    menu.mustasch = love.graphics.newImage("assets/mustasch.png")
    menu.button_w = 300
    menu.button_x = love.graphics.getWidth()/2 - menu.button_w/2
    menu.button_y = 50
    menu.button_h = 100
    
    menu.suit = suit.new()

    -- create options
    menu.options.suit = suit.new()

    -- Set up game state and som graphics settings
    game.state = MENU
    love.graphics.setBackgroundColor(0,0,0,1)
    local font = love.graphics.newFont(20)
    love.graphics.setFont(font)
    game.loadScore()
end


function love.update(dt)
    if game.state == MENU then
        menu.start_button = menu.suit:Button("start",
            menu.button_x,
            menu.button_y,
            menu.button_w,
            menu.button_h
        )
    
        menu.option_button = menu.suit:Button("options",
            menu.button_x,
            menu.button_y + menu.button_h*1 + 10,
            menu.button_w,
            menu.button_h
        )
    
        menu.quit_button = menu.suit:Button("quit",
            menu.button_x,
            menu.button_y + menu.button_h*2 + 20,
            menu.button_w,
            menu.button_h
        )
    

        if menu.start_button.hit then
            game.load_level()
        end

        if menu.option_button.hit then
            game:load_options()
        end

        if menu.quit_button.hit then
            love.event.quit()
        end



        menu.suit:Label("Highscore: "..game.highscore,
            menu.button_x ,
            menu.button_y + menu.button_h*3 + 20,
            menu.button_w,
            menu.button_h 
        )

    elseif game.state == OPTIONS then
        
        menu.options.remove_score = menu.options.suit:Button("remove score",
            menu.button_x,
            menu.button_y,
            menu.button_w,
            menu.button_h
        )

        menu.options.back = menu.options.suit:Button("back",
            menu.button_x,
            menu.button_y + menu.button_h*1 + 10,
            menu.button_w,
            menu.button_h
        )
        if menu.options.remove_score.hit then
            local wasRemoved = game:removeScore()
            menu.options.remove_text = "No Highscore exist yet"
            if wasRemoved then
                menu.options.remove_text = "Highscore was removed"
            end
        end


        if menu.options.remove_text then
            menu.options.suit:Label(menu.options.remove_text,
                menu.button_x ,
                menu.button_y + menu.button_h*3 + 20,
                menu.button_w,
                menu.button_h 
            )
        end

        if menu.options.back.hit then 
            game:load_mainmenu()
        end

    elseif game.state == LEVEL then
        game.ecs:update(dt)
    end

end


function love.draw()
    if game.state == LEVEL then
        game.camera:attach()
        game.manualUpdateSystems.camera:update()
        game.manualUpdateSystems.draw:update()
        game.manualUpdateSystems.overlay:update()
        --game.manualUpdateSystems.write_score:update()
        game.camera:detach()
        --game.manualUpdateSystems.debug_collider:update()
    elseif game.state == MENU then
        love.graphics.draw(
            menu.controlls,
            menu.button_x +350 ,
            menu.button_y + menu.button_h -100,
            0,0.7,0.7)
        menu.suit:draw()

    elseif game.state == OPTIONS then
        menu.options.suit:draw()
    end
    
    if game.state ~= LEVEL then
        love.graphics.draw(
            menu.mustasch,
            menu.button_x  -40,
            menu.button_y + menu.button_h*4 +10,
            0,1,1)
    end
end

