local tiny = require("libs/tiny")

debugsys = {}

-- Draws the colliderbox, must be called after draw, because it will draw upon the same pixels
function debugsys.Collider()
    debug_collider = tiny.processingSystem()

    debug_collider.filter = tiny.requireAll("collider", "position")

    debug_collider.active = false

    function debug_collider:process(entity)
        local ored, ogreen, oblue, oa = love.graphics.getColor()
        love.graphics.setColor(0,255,0)
        love.graphics.rectangle("line", entity.position.x, entity.position.y, entity.collider.w, entity.collider.h)
        love.graphics.setColor(ored,ogreen,oblue)
    end
    return debug_collider
end

return debugsys