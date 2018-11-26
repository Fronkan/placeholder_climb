local component = {}

function component.input()
    return true
end

function component.controller(moveSpeed, jumpSpeed)
    return {
        horizontal = 0,
        vertical = 0,
        jump = false,
        moveSpeed = moveSpeed,
        jumpSpeed = jumpSpeed,
        isGripping_R = false,
        isGripping_L = false
    }
end

function component.scorecounter()
    return {
        score = 0,
        x = 0,
        y = 0,
    }
end

function component.wallslide()
    return {
        left = false,
        right = false
    }
end

function component.gripper(gripTime, gripJumpSpeed)
    return {
        gripResetTime = gripTime,
        isGripping = false,
        canGrip = true,
        reset = false,
        gripTime = gripTime,
        canJump = true,
        jumpSpeed = gripJumpSpeed
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

function component.velocity(x,y, max_x, max_y)
    return {
        x = x or 0,
        y = y or 0,
        max_x = max_x or math.huge,
        max_y = max_y or math.huge
    }
end

function component.acceleration(x,y)
    return {
        x=x,
        y=y
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

function component.crouch(h, original_h)
    return {
        h = h,
        original_h = original_h
    }

end

function component.sprite(path, origin_x, origin_y, scale)
    if path == "placeholder" then
        return {
            image = path,
            origin_x = origin_x,
            origin_y = origin_y,
            scale = 1
        }

    else
        return {
            image = love.graphics.newImage(path),
            origin_x = origin_x,
            origin_y = origin_y,
            scale = scale
        }
    end
end

-- Return the component object to caller
return component