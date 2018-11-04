local component = {}

function component.controller(moveSpeed, jumpSpeed)
    return {
        moveSpeed = moveSpeed,
        jumpSpeed = jumpSpeed,
        isGrounded = false 
    }
end

function component.camerafollow(offset_x, offset_y)
    return {
        offset_x = offset_x,
        offset_y = offset_y
    }
end

function component.position(x,y)
    return {
        x = x,
        y = y
    }
end

function component.velocity(x,y)
    return {
        x = x or 0,
        y = y or 0
    }
end

function component.rigidbody(gravity)
    return {
        gravity = gravity
    }
end

function component.collider(w,h)
    return {
        w = w,
        h = h
    }
end

function component.sprite(path, origin_x, origin_y)
    if path == "placeholder" then
        return {
            image = path,
            origin_x = origin_x,
            origin_y = origin_y
        }

    else
        return {
            image = love.graphics.newImage(path),
            origin_x = origin_x,
            origin_y = origin_y
        }
    end
end

-- Return the component object to caller
return component