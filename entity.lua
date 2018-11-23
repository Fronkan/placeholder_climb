local component = require "component"


local entity = {}

function entity.Player(x, y)
    return {
        camerafollow = true,
        position = component.position(x,y),
        velocity = component.velocity(),
        sprite = component.sprite("placeholder", 50,130),
        collider = component.collider(50, 130),
        crouch = component.crouch(90,130),
        overlay = {image="costume"},
        costume = {"monocle","mustasch"},
        mustasch = component.sprite("assets/mustasch.png", -30,30, 0.3),
        monocle = component.sprite("assets/monocle.png", 28,3, 0.2),
        placeholder_color = {r=200,g=0,b=200},
        input = component.input(),
        controller = component.controller(500, 800),
        rigidbody = component.rigidbody(1000),
        gripper = component.gripper(2, 700),
        wallslide = component.wallslide(),
        destroy = love.load -- This will reset the games, change to a level reset function later 
    }
end

function entity.DebugFlyPlayer(x,y)
    return {
        camerafollow = true,
        position = component.position(x,y),
        velocity = component.velocity(),
        sprite = component.sprite("placeholder", 50,130),
        placeholder_color = {r=255,g=0,b=0},
        input = component.input(),
        controller = component.controller(500, 500),
        --collider = component.collider(50, 130),
        destroy = love.load -- This will reset the games, change to a level reset function later 
    }
end

function entity.Platform(x,y,w,h)
    return {
        position = component.position(x,y),
        sprite = component.sprite("placeholder", w,h),
        collider = component.collider(w,h),
    }
end

function  entity.lava()
    local w = love.graphics.getWidth() + 1000
    local h = love.graphics.getHeight()
    return{
        position = component.position(-500,100),
        velocity = component.velocity(0, -100),
        overlay = component.sprite(
            "placeholder", 
            w,
            h
        ),
        collider = component.collider(w,h),
        placeholder_color = {r=255,b=0,g=0},
        damage = true,
    }
end


-- Return the entity object to caller
return entity