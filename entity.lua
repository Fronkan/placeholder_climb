local component = require "component"


local entity = {}

function entity.Player(x, y)
    return {
        camerafollow = true,
        position = component.position(x,y),
        velocity = component.velocity(),
        sprite = component.sprite("placeholder", 50,130),
        placeholder_color = {r=255,b=0,g=0},
        controller = component.controller(500, 500),
        rigidbody = component.rigidbody(1000),
        collider = component.collider(50, 130),
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


-- Return the entity object to caller
return entity