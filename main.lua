-- Import the sti tools for working with tiled generated map: 
-- This method most likly demands a .lua version of the map
-- Tutorial link: http://lua.space/gamedev/using-tiled-maps-in-love
-- docs: http://karai17.github.io/Simple-Tiled-Implementation/
-- require "libs.sti"
local tiny = require("libs.tiny")

function love.load()
end


function love.update(dt)
    
end


function love.draw()
    local player = {
        pos = {
            x = 100,
            y = 100
        }
    }
    love.graphics.print(player.pos.x, player.pos.y)
end