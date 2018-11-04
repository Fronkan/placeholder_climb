local tiny = require("libs/tiny")
local bump = require("libs/bump")

local system = {}

----------------------------------- DRAW -----------------------------------
function system.Draw()

    draw = tiny.processingSystem()

    draw.filter = tiny.requireAll("position", "sprite")

    draw.active = false -- So we can call it ourselves during love.draw instead of update

    function draw:process(entity)
        if entity.sprite.image == "placeholder" then
            local original_color = nil
            if entity.placeholder_color then
                original_color = {}
                original_color.r, original_color.g, original_color.b, original_color.a = love.graphics.getColor()
                love.graphics.setColor(
                    entity.placeholder_color.r,
                    entity.placeholder_color.g,
                    entity.placeholder_color.b)
            end
            love.graphics.rectangle("fill",entity.position.x ,entity.position.y,entity.sprite.origin_x,entity.sprite.origin_y)
            
            if original_color then
                love.graphics.setColor(original_color.r, original_color.g, original_color.b)
            end
        else
            love.graphics.draw(
                entity.sprite.image,
                entity.position.x,
                entity.position.y,
                0,
                0,
                0,
                entity.sprite.origin_x,
                entity.sprite.origin_y)
        end
    end

    return draw
end

----------------------------------- CONTROLLER -----------------------------------
function system.Controller()
    controller = tiny.processingSystem()
    
    controller.filter = tiny.requireAll("velocity", "controller")
    
    function controller:process(entity)   
        if love.keyboard.isDown("right") then 
            entity.velocity.x = entity.controller.moveSpeed
        elseif love.keyboard.isDown("left") then
            entity.velocity.x = - entity.controller.moveSpeed
        else
            entity.velocity.x = 0
        end

        if love.keyboard.isDown("space") and entity.isGrounded then
            entity.velocity.y = - entity.controller.jumpSpeed
        end

    end

    return controller
end

----------------------------------- PHYSICS -----------------------------------
function system.Physics()
    physics = tiny.processingSystem()
    
    physics.filter  = tiny.requireAll("position", "collider")
    
    physics.bumpWorld = bump.newWorld()

    function physics.collisionFilter(e1,e2)
        return "slide"
    end

    function physics:process(entity, dt)
        local pos = entity.position
        local gravity = 0
        if entity.rigidbody then
            gravity = entity.rigidbody.gravity
        end

        if entity.velocity then
            local vel = entity.velocity
            vel.y = vel.y + gravity * dt
            local actualX, actualY, cols, numCols = self.bumpWorld:move(entity, pos.x + vel.x * dt, pos.y + vel.y * dt, self.collisionFilter)
            pos.x = actualX
            pos.y = actualY

            if numCols == 0 then
                    entity.isGrounded = nil
                return
            end

            for i, col in ipairs(cols) do
                if col.type == "touch" then
                    vel.y = 0
                    vel.x = 0
                elseif col.type == "slide" then
                    if col.normal.x ~= 0 then
                        vel.x = 0
                    else
                        vel.y = 0 
                    end

                    if col.normal.y == -1 then
                        entity.isGrounded = true
                    else 
                        entity.isGrounded = nil
                    end
                end

            end

        end
    end

    function physics:onAdd(entity)
        local pos = entity.position
        local collider = entity.collider
        self.bumpWorld:add(entity, pos.x, pos.y, collider.w, collider.h)
    end

    function physics:onRemove(entity)
        self.bumpWorld:remove(entity)
    end

    return physics
end 

----------------------------------- CAMERA -----------------------------------

function system.Camera()
    camera = tiny.processingSystem()
    camera.filter = tiny.requireAll("camerafollow", "position")
    camera.active = false

    function camera:process(entity, dt)
        local offset_y = love.graphics.getHeight()/2
        local offset_x = love.graphics.getWidth()/2
        love.graphics.translate(-entity.position.x + offset_x,0)-- -entity.position.y + offset_y)
    end

    return camera
end
-- Potential solution if camera is of type system istead of processing system. 
-- Might be good if multiple targets is used
--[[
function system.camera:update(dt)
    local entities = self.world.entities
    local filter = self.filter
    local x = 0
    local y = 0
    local numTargets = 0
    
    if filter then
        for i = 1, #entities do
            local entity = entities[i]
            if filter(system, entity) then
                x = x + entity.position.x 
                y = y + entity.position.y
                numTargets = numTargets +1
            end
        end
        if numTargets ~= 0 then
            x = x/numTargets
            y = y/numTargets
        end
    end
    local offset_y = love.graphics.getHeight()/2
    local offset_x = love.graphics.getWidth()/2
    love.graphics.translate(-x + offset_x, -y + offset_y)
end

]]--

-- Removes items outside the world bounderies from the ecs system and calls their destory method
function system.OutOfBounds(limit_x, limit_y)
    outofbounds = tiny.processingSystem()
    outofbounds.limit_x = limit_x
    outofbounds.limit_y = limit_y
    
    outofbounds.filter = tiny.requireAll("position", "destroy")
    
    function outofbounds:process(entity, dt)
        if math.abs(entity.position.x) >= self.limit_x or math.abs(entity.position.y) >= self.limit_y then
            self.world:remove(entity)
            entity.destroy()
        end
    end

    return outofbounds
end


return system