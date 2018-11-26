local tiny = require("libs/tiny")
local bump = require("libs/bump")
local entity = require("entity")
local vector = require("libs/hump/vector")
require("utils")


local system = {}

----------------------------------- DRAW -----------------------------------
function system.Draw()

    local draw = tiny.processingSystem()

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
            if entity.isCrouching and entity.crouch then
                love.graphics.rectangle("fill",entity.position.x ,entity.position.y,entity.sprite.origin_x,entity.crouch.h)
            else
                love.graphics.rectangle("fill",entity.position.x ,entity.position.y,entity.sprite.origin_x,entity.sprite.origin_y)
            end
            if original_color then
                love.graphics.setColor(original_color.r, original_color.g, original_color.b)
            end
        else
            love.graphics.draw(
                entity.sprite.image,
                entity.position.x + entity.sprite.origin_x,
                entity.position.y + entity.sprite.origin_y,
                0,
                entity.sprite.scale,
                entity.sprite.scale)
        end
    end

    return draw
end


function system.Overlay()
    local overlay = tiny.processingSystem()

    overlay.filter = tiny.requireAll("position", "overlay")

    overlay.active = false -- So we can call it ourselves during love.draw instead of update

    function overlay:process(entity)

        if entity.overlay.image == "placeholder" then
            local original_color = nil
            if entity.placeholder_color then
                original_color = {}
                original_color.r, original_color.g, original_color.b, original_color.a = love.graphics.getColor()
                love.graphics.setColor(
                    entity.placeholder_color.r,
                    entity.placeholder_color.g,
                    entity.placeholder_color.b)
            end
            love.graphics.rectangle("fill",entity.position.x ,entity.position.y,entity.overlay.origin_x,entity.overlay.origin_y)
            
            if original_color then
                love.graphics.setColor(original_color.r, original_color.g, original_color.b)
            end
        elseif entity.overlay.image == "costume" then
            for i,costume_part in ipairs(entity.costume) do
                love.graphics.draw(
                    entity[costume_part].image,
                    entity.position.x + entity[costume_part].origin_x,
                    entity.position.y + entity[costume_part].origin_y,
                    0,
                    entity[costume_part].scale,
                    entity[costume_part].scale)
            end
        else
            love.graphics.draw(
                entity.overlay.image,
                entity.position.x + entity.overlay.origin_x,
                entity.position.y + entity.overlay.origin_y,
                0,
                entity.overlay.scale,
                entity.overlay.scale)
        end
    end

    return overlay
end

----------------------------------- CONTROLLER -----------------------------------
function system.Input()
    local input = tiny.processingSystem()
    input.filter = tiny.requireAll("controller", "input")

    function input:process(entity)
        if love.keyboard.isDown("right") then
            entity.controller.horizontal = 1
            entity.controller.isGripping_R = true
            entity.controller.isGripping_L = false
        elseif love.keyboard.isDown("left") then
            entity.controller.isGripping_L = true
            entity.controller.isGripping_R = false
            entity.controller.horizontal = -1
        else
            entity.controller.isGripping_L = false
            entity.controller.isGripping_R = false
            entity.controller.horizontal = 0 
        end
         

        if love.keyboard.isDown("down") then
            entity.controller.vertical = 1
        elseif love.keyboard.isDown("up") then
            entity.controller.vertical = -1
        else
            entity.controller.vertical = 0 
        end

        if love.keyboard.isDown("space") then
            entity.controller.jump = true
        else
            entity.controller.jump = false
        end

    end

    return input
end


function system.Controller()
    local controller = tiny.processingSystem()
    
    controller.filter = tiny.requireAll("velocity", "controller")
    
    function controller:process(entity)   

        entity.velocity.x = entity.controller.horizontal * entity.controller.moveSpeed

        if entity.controller.vertical > 0 then
            entity.isCrouching = true
        else
            entity.isCrouching = false
        end

        if entity.controller.jump then
            if entity.isGrounded then 
                entity.velocity.y = - entity.controller.jumpSpeed
            elseif entity.gripper and entity.gripper.canJump and entity.gripper.isGripping then
                entity.velocity.y = - entity.gripper.jumpSpeed
                entity.gripper.canJump = false
            end
        end

    end

    return controller
end


function system.Gripping()
    local gripping = tiny.processingSystem()
    gripping.filter = tiny.requireAll("gripper", "velocity", "controller", "wallslide")
    function gripping:process(entity, dt)
        local gripper = entity.gripper
        local can_grip_L = (entity.controller.isGripping_L 
                            and entity.wallslide.left 
                            and gripper.canGrip)
                            
        local can_grip_R = (entity.controller.isGripping_R 
                            and entity.wallslide.right 
                            and gripper.canGrip)
        local vel = entity.velocity

        if can_grip_L then
            gripper.isGripping = true
        elseif can_grip_R then
            gripper.isGripping = true
        else
            gripper.isGripping = false
        end

        if gripper.isGripping then
            gripper.gripTime = gripper.gripTime - dt
        end

        if gripper.gripTime <= 0 then
            gripper.canGrip = false
        end

        if gripper.canGrip and gripper.isGripping then
            if vel.y > 0 then vel.y=0 end
        end

        if entity.isGrounded then
            gripper.canJump = true
            gripper.gripTime = gripper.gripResetTime
            gripper.canGrip = true
        end
    end
    return gripping
end

----------------------------------- PHYSICS -----------------------------------
function system.Gravity()
    local gravity = tiny.processingSystem()
    gravity.filter = tiny.requireAll("position","velocity","rigidbody")
    
    function gravity:process(entity, dt)
        local pos = entity.position 
        local vel = entity.velocity
        vel.y = vel.y + entity.rigidbody.gravity * dt
    end

    return gravity
end 

function system.Accelerator()
    local acc_sys = tiny.processingSystem()
    acc_sys.filter = tiny.requireAll("velocity", "acceleration")

    function acc_sys:process(entity, dt)
        local vel = entity.velocity
        local acc = entity.acceleration
        vel.y = vel.y + acc.y*dt
        vel.x = vel.x + acc.x*dt
    end
    return acc_sys
end


function system.MoveWithCollision()
    local moveWithCollision = tiny.processingSystem()   
    moveWithCollision.filter  = tiny.requireAll("position","collider")
    moveWithCollision.bumpWorld = bump.newWorld()

    function moveWithCollision.collisionFilter(e1,e2)
        if e1.damage or e2.damage then
            return "cross"
        else
            return "slide"
        end
    end

    function moveWithCollision:process(entity, dt)
        local pos = entity.position
        if not entity.velocity then
            return
        end

        if entity.crouch then
            local diff = entity.crouch.h - entity.crouch.original_h

            if entity.isCrouching and entity.collider.h ~= entity.crouch.h then
                entity.collider.h = entity.crouch.h
                pos.y = pos.y - diff
                self.bumpWorld:update(
                    entity,
                    pos.x,
                    pos.y,
                    entity.collider.w,
                    entity.crouch.h
                )
            elseif not entity.isCrouching then
                function filter(item)
                    if item.controller then return false else return true end
                end
                if entity.collider.h ~= entity.crouch.original_h then
                    cols, len = self.bumpWorld:queryRect(
                        pos.x,
                        pos.y + diff,
                        entity.collider.w,
                        entity.crouch.original_h,
                        filter
                    )
                    if len == 0 then
                        entity.collider.h = entity.crouch.original_h
                        self.bumpWorld:update(
                            entity,
                            pos.x,
                            pos.y - (entity.crouch.original_h - entity.crouch.h),
                            entity.collider.w,
                            entity.crouch.original_h
                        )
                    else
                        entity.isCrouching = true
                    end
                end
            end   
        end

        -- We know we have velocity because of guard clause in top of function.
        local vel = entity.velocity
        vel.y = clamp_abs(vel.y, vel.max_y)
        vel.x = clamp_abs(vel.x, vel.max_x)
        
        local actualX, actualY, cols, numCols = self.bumpWorld:move(entity, pos.x + vel.x * dt, pos.y + vel.y * dt, self.collisionFilter)
        pos.x = actualX
        pos.y = actualY

        if numCols == 0 then
            entity.isGrounded = nil
            if entity.wallslide then
                entity.wallslide.left = false
                entity.wallslide.right = false
            end
            return
        end

        for i, col in ipairs(cols) do
            if col.type == "touch" then
                vel.y = 0
                vel.x = 0
            elseif col.type == "slide" then
                if col.normal.x ~= 0 then
                    vel.x = 0
                    if entity.wallslide then
                        if col.normal.x == -1 then
                            entity.wallslide.left = false
                            entity.wallslide.right = true
                        elseif col.normal.x == 1 then
                            entity.wallslide.left = true
                            entity.wallslide.right = false
                        end
                    end

                else
                    if entity.wallslide then
                        entity.wallslide.left = false
                        entity.wallslide.right = false
                    end
                    vel.y = 0 
                end

                if col.normal.y == -1 then
                    entity.isGrounded = true
                else 
                    entity.isGrounded = nil
                end
            elseif col.type == "cross" then
                if entity.destroy and col.other.damage then
                    entity.destroy()
                end
            end
        end
    end

    
    function moveWithCollision:onAdd(entity)
        local pos = entity.position
        local collider = entity.collider
        self.bumpWorld:add(entity, pos.x, pos.y, collider.w, collider.h)
    end

    function moveWithCollision:onRemove(entity)
        self.bumpWorld:remove(entity)
    end

    return moveWithCollision
end


function system.MoveNoCollision()
    local moveNoCollision = tiny.processingSystem()
    moveNoCollision.filter = tiny.requireAll("position","velocity")

    function moveNoCollision:process(entity,dt)
        local pos = entity.position
        local vel = entity.velocity
        pos.x = pos.x + vel.x * dt
        pos.y = pos.y + vel.y * dt
    end

    return moveNoCollision
end


----------------------------------- CAMERA -----------------------------------
function system.Camera()
    local camera = tiny.processingSystem()
    camera.filter = tiny.requireAll("camerafollow", "position")
    camera.active = false

    function camera:process(entity, dt)
        local pos = entity.position
        --local dx,dy = pos.x - game.camera.x, pos.y - game.camera.y
        local dx,dy = 0, pos.y - game.camera.y
        game.camera:move(dx/2, dy/2)
    end

    return camera
end

-- Removes items outside the world bounderies from the ecs system and calls their destory method
function system.OutOfBounds(limit_x, limit_y)
    local outofbounds = tiny.processingSystem()
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


----------------------------------- WORLD GENERATOR -----------------------------------


local blocks = {{w=200, h=200},{w=100, h=300},{w=150, h=50}, {w=100,h=100}, {w=100,h=30}, {w=50,h=200}, {w=50,h=50}}

function system.WorldGenerator(chunk_size_x,chunk_size_y, ecs_world)
    local world_generator = tiny.processingSystem()
    world_generator.filter = tiny.requireAll("controller", "position")


    function world_generator:generate_chunk(center_y) 
        --x = love.math.random(50,limit_x)
        --x = 0 --love.graphics.getWidth()/2
        --y = pos_y + love.math.random(0, chunk_size_y/2)
        --y= center_y - chunk_size_y/2
        --w = love.math.random(100, 500)
        --w = love.graphics.getWidth()/2
        --h = love.math.random(100, 300)
        --h = chunk_size_y
        local blocks_to_spawn = 35
        positions = {}
        time_out = 20 * blocks_to_spawn
        time_cnt = 0
        while #positions <=blocks_to_spawn do
            local new_pos = vector(love.math.random(-chunk_size_x/2, chunk_size_x/2), center_y - love.math.random(0, chunk_size_y))
            local too_close  = false
            for i,vec in ipairs(positions) do
                --print(vec)
                if new_pos:dist(vec) <=300 then
                    too_close = true
                    break
                end
            end
            -- TODO Add some vector math using HUMP and check the distance between blocks så they are not too close to each other
            -- And if they are not add them to the chunk!
            if too_close == false then
                table.insert(positions, new_pos)
            end
            time_cnt = time_cnt +1
            if time_cnt == time_out then
                break;
            end
        end

        for i,pos in ipairs(positions) do
            x = pos.x 
            y = pos.y 
            block = blocks[love.math.random(1, #blocks)]
            w = block.w
            h = block.h
            tiny.add(ecs_world,entity.Platform(x,y,w,h))
        end


    end
    
    world_generator:generate_chunk(0)



    world_generator.last_chunk = -1
    function world_generator:process(entity)
        chunk_num = 1 + math.abs(math.floor(entity.position.y/chunk_size_y))
        if chunk_num >= self.last_chunk then
            self:generate_chunk(-chunk_num * chunk_size_y + chunk_size_y)
            self.last_chunk = chunk_num + 1
        end

    end

    -- Version for moving down
    --[[
    world_generator.last_chunk = -1
    function world_generator:process(entity)
        chunk_num = 2 +  math.floor(entity.position.y/chunk_size_y)
        print("curr_chunk: ", chunk_num)
        if chunk_num >= self.last_chunk then
            print("Spawned")
            self:generate_chunk(chunk_num * chunk_size_y)
            self.last_chunk = chunk_num + 1
        end

    end
    ]]--
    
    
    return world_generator
end

----------------------------------- SCORE -----------------------------------
function system.ScoreCount()
    local score = tiny.processingSystem()
    score.filter = tiny.requireAll("scorecounter", "position")
    local start_pos = 0    
    function calc_score(pos_y)

        return math.floor((-pos_y + start_pos)/10)
    end
    local is_first = true

    function score:process(entity)
        if is_first then
            start_pos = entity.position.y
            is_first = false
        end
        local offset_y = love.graphics.getHeight()/2
        --love.graphics.translate(-entity.position.x + offset_x,0)-- -entity.position.y + offset_y)
        love.graphics.translate(0,-entity.position.y + offset_y)
        local sc = entity.scorecounter
        local newScore = calc_score(entity.position.y)
        if sc.score <= newScore then
            sc.score = newScore
        end
        sc.y = entity.position.y - offset_y
    end
    return score
end


function system.WriteScore()
    local sc_draw = tiny.processingSystem()
    sc_draw.filter = tiny.requireAll("scorecounter")

    function sc_draw:process(entity)
        local sc = entity.scorecounter
        local r,g,b,a = love.graphics.getColor()
        love.graphics.setColor(0,0,0,1)
        love.graphics.printf("Score: " .. sc.score, sc.x,sc.y, 400, "left", 0)
        love.graphics.setColor(r,g,b,a)

    end
    sc_draw.active = false

    return sc_draw
end

return system